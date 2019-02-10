/* Author: Peter Rogelj <peter.rogelj@upr.si> */

#include <math.h>
// #include <matrix.h> //PRJ 2017-05-05
#include <mex.h>

//-------------
#include <iostream>
#include <stdint.h>


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Description: compute inverse of the deformation field
     * The inverse deformation field could in theory be used to transform resampled deformed image into original one
     * Input:
     *      - REG.img structure - just an img part
     * Outputs:
     *      - D - deformation field that is inverse of the field provided in the source image
    */

    if (nrhs!=1)
        mexErrMsgTxt("Required input paremeter: REG img structure!");
    if(!mxIsStruct(prhs[0]))
        mexErrMsgTxt("First input parameter must be a structure!");

    float SX,SY,SZ; // voxel size
    float OX,OY,OZ; // origin
    int NX,NY,NZ,NXY,NXYZ; // image size
    float *pDX,*pDY,*pDZ; // deformation field pointers
    float *pDXO,*pDYO,*pDZO; // resulting deformation field pointers

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

    // check if T exists... should not
    // T - transformation of the moving image -----------------------------
    if ((myarray = mxGetField(prhs[0], 0, "T"))!=NULL) {
        const mwSize *dataSize = mxGetDimensions(myarray);
        if (dataSize[0]>0)
            mexErrMsgTxt("Image should not be transformed - change T to D using T2D prior to inverseD!");
    }

    // D - deformation field ----------------------------------------------
    if ((myarray = mxGetField(prhs[0], 0, "D"))==NULL)
        mexErrMsgTxt("The image is not deformed - does not include the deformation field (D)!");
    if (!mxGetNumberOfElements(myarray))
        mexErrMsgTxt("The image does not seem to be deformed! Empty D?");

    const mwSize *dataSize = mxGetDimensions(myarray);
    NX=dataSize[0];
    NY=dataSize[1];
    NZ=dataSize[2];
    if (NX<=1 || NY<1 || NZ<1 || dataSize[3]!=3){
        mexErrMsgTxt("The image does not seem to have a valid deformation field (D) according to its size!");
    }
    if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the moving img deformation field (D), must be single!");
    pDX=(float*)mxGetData(myarray);

    NXY=NX*NY;
    NXYZ=NXY*NZ;
    pDY= pDX+NXYZ;
    pDZ= pDY+NXYZ;

    //=====================================================================

    //define the output data

    // define a new matrix D (resulting displacement grid)
    mwSize DSize[4];
    DSize[0]=NX;
    DSize[1]=NY;
    DSize[2]=NZ;
    DSize[3]=3;
    //mxArray *mxCreateNumericArray(mwSize ndim, const mwSize *dims, mxClassID classid, mxComplexity ComplexFlag);
    plhs[0] = mxCreateNumericArray(4,DSize,mxSINGLE_CLASS,mxREAL); // the data should already get initialized to 0!
    pDXO= (float*) mxGetData(plhs[0]);
    pDYO= pDXO+NXYZ;
    pDZO= pDYO+NXYZ;

    // initialize temporary processing fields
    float *pW;
    pW =  (float*) malloc (NXYZ*sizeof(float));
    float * pWt=pW;
    for (int i=0; i<NXYZ; i++) {
        *pWt=0;
        pWt++;
    }

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
            dx=*pDXt; pDXt++;
            dy=*pDYt; pDYt++;
            dz=*pDZt; pDZt++;
            x1=x+dx;
            y1=y+dy;
            z1=z+dz;


            // if (Transf){...}

            // x1,y1,z1 are now positions in mm.

            x2=(x1+OX)/SX;
            y2=(y1+OY)/SY;
            z2=(z1+OZ)/SZ;
            X1=floor(x2);
            Y1=floor(y2);
            Z1=floor(z2);

            if ( (X1<0)||(Y1<0)||(Z1<0) || (X1>NX-1)||(Y1>NY-1)||(Z1>NZ-1) )  continue;

            x1=x2-X1;
            y1=y2-Y1;
            z1=z2-Z1;
            dptr=X1+NX*(Y1+NY*Z1);
            pDXOt=pDXO+dptr;
            pDYOt=pDYO+dptr;
            pDZOt=pDZO+dptr;
            pWt=pW+dptr;


            tmp=(1-x1)*(1-y1)*(1-z1);
            *pDXOt+=dx*tmp;
            *pDYOt+=dy*tmp;
            *pDZOt+=dz*tmp;
            *pWt+=tmp;

            if ( (X1<NX-1) ) {
              tmp=(x1)*(1-y1)*(1-z1);
              dptr=1;
              *(pDXOt+dptr)+=dx*tmp;
              *(pDYOt+dptr)+=dy*tmp;
              *(pDZOt+dptr)+=dz*tmp;
              *(pWt+dptr)+=tmp;
            }

            if ( (Y1<NY-1) ) {
              tmp=(1-x1)*(y1)*(1-z1);
              dptr=NX;
              *(pDXOt+dptr)+=dx*tmp;
              *(pDYOt+dptr)+=dy*tmp;
              *(pDZOt+dptr)+=dz*tmp;
              *(pWt+dptr)+=tmp;
            }

            if ( (X1<NX-1) && (Y1<NY-1) ) {
              tmp=(x1)*(y1)*(1-z1);
              dptr=1+NX;
              *(pDXOt+dptr)+=dx*tmp;
              *(pDYOt+dptr)+=dy*tmp;
              *(pDZOt+dptr)+=dz*tmp;
              *(pWt+dptr)+=tmp;
            }

            if ( (Z1<NZ-1) ) {
              tmp=(1-x1)*(1-y1)*(z1);
              dptr=NXY;
              *(pDXOt+dptr)+=dx*tmp;
              *(pDYOt+dptr)+=dy*tmp;
              *(pDZOt+dptr)+=dz*tmp;
              *(pWt+dptr)+=tmp;
            }

            if ( (X1<NX-1) && (Z1<NZ-1) ) {
              tmp=(x1)*(1-y1)*(z1);
              dptr=1+NXY;
              *(pDXOt+dptr)+=dx*tmp;
              *(pDYOt+dptr)+=dy*tmp;
              *(pDZOt+dptr)+=dz*tmp;
              *(pWt+dptr)+=tmp;
            }

            if ( (Y1<NY-1) && (Z1<NZ-1) ) {
              tmp=(1-x1)*(y1)*(z1);
              dptr=NX+NXY;
              *(pDXOt+dptr)+=dx*tmp;
              *(pDYOt+dptr)+=dy*tmp;
              *(pDZOt+dptr)+=dz*tmp;
              *(pWt+dptr)+=tmp;
            }

            if ( (X1<NX-1) && (Y1<NY-1) && (Z1<NZ-1) ) {
              tmp=(x1)*(y1)*(z1);
              dptr=1+NX+NXY;
              *(pDXOt+dptr)+=dx*tmp;
              *(pDYOt+dptr)+=dy*tmp;
              *(pDZOt+dptr)+=dz*tmp;
              *(pWt+dptr)+=tmp;
            }

        } //px
      } //py
    } //pz


    pDXOt=pDXO;  pDYOt=pDYO;  pDZOt=pDZO;  pWt=pW;
    for(int pz=0;pz<NZ;pz++){
      for(int py=0;py<NY;py++){
        for(int px=0;px<NX;px++){
          if (*pWt!=0) {
            *pDXOt = - *pDXOt / *pWt;
            *pDYOt = - *pDYOt / *pWt;
            *pDZOt = - *pDZOt / *pWt;
            *pWt=1;
          }
          pDXOt++; pDYOt++; pDZOt++;
          pWt++;
        }
      }
    }  //pz


    // izloèanje nedoloèenih premikov  (pri *Wt=0)   tu realno delamo napako!!!
    int Num=1;
    while (Num!=0){
      Num=0;
      pDXOt=pDXO;  pDYOt=pDYO;  pDZOt=pDZO;  pWt=pW;
      for(int pz=0;pz<NZ;pz++){
        for(int py=0;py<NY;py++){
          for(int px=0;px<NX;px++){
            if (*pWt==0) {

              if (px>0) {
                dptr=-1;
                *pWt+=*(pWt+dptr);
                *pDXOt+=*(pDXOt+dptr);
                *pDYOt+=*(pDYOt+dptr);
                *pDZOt+=*(pDZOt+dptr);
              }
              if (px<NX-1) {
                dptr=1;
                *pWt+=*(pWt+dptr);
                *pDXOt+=*(pDXOt+dptr);
                *pDYOt+=*(pDYOt+dptr);
                *pDZOt+=*(pDZOt+dptr);
              }
              if (py>0) {
                dptr=-NX;
                *pWt+=*(pWt+dptr);
                *pDXOt+=*(pDXOt+dptr);
                *pDYOt+=*(pDYOt+dptr);
                *pDZOt+=*(pDZOt+dptr);
              }
              if (py<NY-1) {
                dptr=NX;
                *pWt+=*(pWt+dptr);
                *pDXOt+=*(pDXOt+dptr);
                *pDYOt+=*(pDYOt+dptr);
                *pDZOt+=*(pDZOt+dptr);
              }
              if (pz>0) {
                dptr=-NXY;
                *pWt+=*(pWt+dptr);
                *pDXOt+=*(pDXOt+dptr);
                *pDYOt+=*(pDYOt+dptr);
                *pDZOt+=*(pDZOt+dptr);
              }
              if (pz<NZ-1) {
                dptr=NXY;
                *pWt+=*(pWt+dptr);
                *pDXOt+=*(pDXOt+dptr);
                *pDYOt+=*(pDYOt+dptr);
                *pDZOt+=*(pDZOt+dptr);
              }

              if (*pWt!=0){
                *pDXOt = *pDXOt / *pWt;
                *pDYOt = *pDYOt / *pWt;
                *pDZOt = *pDZOt / *pWt;
                *pWt=1;
                Num++;
              }
            }
            pDXOt++;  pDYOt++;  pDZOt++;  pWt++;
          }
        }
      }
      //to continue Num must be 0;
    } // while num!=0
    free (pW);

} //end
//-----------------------------------------------------------------------------
