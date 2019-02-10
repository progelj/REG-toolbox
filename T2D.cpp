/* Author: Peter Rogelj <peter.rogelj@upr.si> */

#include <math.h>
// #include <matrix.h> //PRJ 2017-05-05
#include <mex.h>

//-------------
#include <iostream>
#include <stdint.h>


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Description: compute displacement field considerting the transformation matrix T.
     * The inverse deformation field could in theory be used to transform resampled deformed image into original one
     * Input:
     *      - REG.img structure - just an img part
     * Outputs:
     *      - D - displacement/deformation field of the image.
    */

    if (nrhs!=1)
        mexErrMsgTxt("Required input paremeter: REG img structure!");
    if(!mxIsStruct(prhs[0]))
        mexErrMsgTxt("First input parameter must be a structure!");

    bool Transf, Deform;
    float SX,SY,SZ; // voxel size
    float OX,OY,OZ; // origin
    int NX,NY,NZ,NXY,NXYZ; // image size
    float *pDX,*pDY,*pDZ; // deformation field pointers
    float *pDXO,*pDYO,*pDZO; // resulting deformation field pointers
    float *pT, *pT1;

    //=====================================================================
    //Get image data: {voxelSize,data, O,D,T}
    //voxel size:
    mxArray *myarray;
    if ((myarray = mxGetField(prhs[0], 0, "voxelSize"))==NULL) mexErrMsgTxt("Voxel size dimmension of the reference image is not defined!");
    size_t voxSizeDim = mxGetNumberOfElements(myarray);
    if (voxSizeDim!=3) mexErrMsgTxt("Invalid voxel size dimmension of ref. img, must be 3!");
    if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the ref img voxelSize, must be single!");
    float *voxSize = (float*)mxGetData(myarray);
    SX=voxSize[0]; SY=voxSize[1]; SZ=voxSize[2];
    //mexPrintf("voxSizeR: %f x %f x %f\n", SXR, SYR, SZR);


    // O- origin ----------------------------------------------------------
    float *O;
    myarray = mxGetField(prhs[0], 0, "O");
    if (myarray==NULL) { // origin is (0,0,0)
        OX=0; OY=0; OZ=0;
    }
    else {
        size_t dim = mxGetNumberOfElements(myarray);
        if (dim!=3) mexErrMsgTxt("Invalid origin dimmension of ref. img, must be 3!");
        if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the ref img origin (O), must be single!");
        O = (float*)mxGetData(myarray);
        OX=O[0]; OY=O[1]; OZ=O[2];
    }
    //mexPrintf("Reference origin: %f x %f x %f\n", OXR, OYR, OZR);

    // data - for image size (in voxels) -------------------------
    if ((myarray = mxGetField(prhs[0], 0, "data"))==NULL) mexErrMsgTxt("Image data of ref. img is not defined!");
    const mwSize *dataSize = mxGetDimensions(myarray);
    NX=dataSize[0]; NY=dataSize[1]; NZ=dataSize[2];
    NXY=NX*NY; NXYZ=NXY*NZ;
    //mexPrintf("Ref data size: %d x %d x %d\n", NXR, NYR, NZR);

    // T - transformation of the moving image -----------------------------
    if ((myarray = mxGetField(prhs[0], 0, "T"))==NULL) {
        Transf=false;
        //mexPrintf("Image is not transformed, nothing to do in T2D.\n"); //mexWarnMsgTxt
        //return;
    } else {
        dataSize = mxGetDimensions(myarray);
        if (dataSize[0]==4 && dataSize[1]==4) {
            if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the moving img T, must be single!");
            pT=(float*)mxGetData(myarray);
            Transf=true;
        } else {
            Transf=false;
        }
    }
    //mexPrintf("Image is transformed? %d \n", (int)Transf);

    // D - deformation field of the moving image --------------------------
    Deform=false;
    if ((myarray = mxGetField(prhs[0], 0, "D"))!=NULL) {
        if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the moving img deformation field (D), must be single!");
        dataSize = mxGetDimensions(myarray);
        if ((int)mxGetNumberOfElements(myarray)!=NXYZ*3) { //if (dataSize[0]!=NX || dataSize[1]!=NY || dataSize[2]!=NZ) {
            Deform=false;
        } else {
            Deform=true;
            pDX=(float*)mxGetData(myarray);
            pDY= pDX+NXYZ;
            pDZ= pDY+NXYZ;
        }
    }
    else {
        Deform=false;
    }

    //=====================================================================
    // define the output
    // ====================================================================

    // define a new matrix D (resulting displacement grid)
    mwSize DSize[4]={NX,NY,NZ,3};
    //DSize[0]=NX;
    //DSize[1]=NY;
    //DSize[2]=NZ;
    //DSize[3]=3;
    //mxArray *mxCreateNumericArray(mwSize ndim, const mwSize *dims, mxClassID classid, mxComplexity ComplexFlag);
    plhs[0] = mxCreateNumericArray(4,DSize,mxSINGLE_CLASS,mxREAL); // the data should already get initialized to 0!
    pDXO= (float*) mxGetData(plhs[0]);
    pDYO= pDXO+NXYZ;
    pDZO= pDYO+NXYZ;

    //=====================================================================
    // computation part
    // ====================================================================
    float *pDXt,*pDYt,*pDZt;
    float *pDXOt,*pDYOt,*pDZOt;

    double x,y,z,x1,y1,z1,x2,y2,z2,dx,dy,dz;   //temp positions
    int X1,Y1,Z1;
    long int dptr; // pointer shift to current element
    double tmp;

    pDXt=pDX; pDYt=pDY; pDZt=pDZ;
    pDXOt=pDXO; pDYOt=pDYO; pDZOt=pDZO;

    for (int pz=0;pz<NZ;pz++){         //along input image
      for (int py=0;py<NY;py++){
        for (int px=0;px<NX;px++){

            x=px*SX-OX;
            y=py*SY-OY;
            z=pz*SZ-OZ;

            if (Deform) {
                x1=x+*pDXt; pDXt++;
                y1=y+*pDYt; pDYt++;
                z1=z+*pDZt; pDZt++;
            } else {
                x1=x;
                y1=y;
                z1=z;
            }

            //mexPrintf("%f %f %f ---",x1,y1,z1);

            if (Transf) {
            // transform
                pT1=pT;
                x2=  x1**pT1; pT1++;
                y2=  x1**pT1; pT1++;
                z2=  x1**pT1; pT1++;
                pT1++;
                x2+= y1**pT1; pT1++;
                y2+= y1**pT1; pT1++;
                z2+= y1**pT1; pT1++;
                pT1++;
                x2+= z1**pT1; pT1++;
                y2+= z1**pT1; pT1++;
                z2+= z1**pT1; pT1++;
                pT1++;
                x2+=   *pT1; pT1++;
                y2+=   *pT1; pT1++;
                z2+=   *pT1;
            } else {
                x2=x1;
                y2=y1;
                z2=z1;
            }

            //mexPrintf("%f %f %f \n",x2,y2,z2);

            // x1,y1,z1 are now positions in mm.
            *pDXOt=x2-x;
            *pDYOt=y2-y;
            *pDZOt=z2-z;

            pDXOt++;
            pDYOt++;
            pDZOt++;

        } //px
      } //py
    } //pz


} //end
//-----------------------------------------------------------------------------
