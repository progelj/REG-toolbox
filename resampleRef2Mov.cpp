/* Author: Peter Rogelj <peter.rogelj@upr.si> */

#include <math.h>
// #include <matrix.h> //PRJ 2017-05-05
#include <mex.h>

//-------------
#include <iostream>
#include <stdint.h>
#include "mexcpp.h"  //see https://github.com/kuitang/mexcpp
using namespace mexcpp;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Description: Resample the reference image to match the
        (optionally trensformed/deformed) moving image.
       The resulting image has the same dimmension/voxel size/origin...  (actually also T and D - both images share the same spatial properties -are overlayed ;-)
        as the moving image
       The result is only the img.data field!

       Input parameters:
        REG structure with loaded images
       Return:
        resampled data of reference image (the img.data matrix)
    */
    if (nrhs!=1)
        mexErrMsgTxt("Required input paremeter: REG structure!");
    if(!mxIsStruct(prhs[0]))
        mexErrMsgTxt("First input parameter must be a structure!");

    // read refIdx and movIdx:
    //------------------------
    StructMat sm(prhs[0]);
    int refIdx  = sm.getS<int32_t>("refIdx")-1;
    int movIdx  = sm.getS<int32_t>("movIdx")-1;
    //mexPrintf("refIdx: %d , movIdx: %d\n", refIdx+1, movIdx+1);


    mxArray *img;
    if ((img = mxGetField(prhs[0], 0, "img"))==NULL) mexErrMsgTxt("Invalid REG structure, missing images img!");
    //=====================================================================
    //define variables:

    bool Transf, Deform;
    int NXR,NYR,NZR,NXYR,NXYZR, NXO,NYO,NZO,NXYZO;
    float OXR,OYR,OZR, OXO,OYO,OZO;
    float SXR,SYR,SZR, SXO,SYO,SZO;
    float *pDXO,*pDYO,*pDZO;
    float *pT, *pTtmp;
    uint8_t *pMR, *pMR0;

    //=====================================================================
    //Get reference image data: img(refIdx).{voxelSize,data, O,D,T}
    //voxel size:
    mxArray *myarray;
    if ((myarray = mxGetField(img, refIdx, "voxelSize"))==NULL) mexErrMsgTxt("Voxel size dimmension of the reference image is not defined!");
    size_t voxSizeDim = mxGetNumberOfElements(myarray);
    if (voxSizeDim!=3) mexErrMsgTxt("Invalid voxel size dimmension of ref. img, must be 3!");
    if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the ref img voxelSize, must be single!");
    float *voxSize = (float*)mxGetData(myarray);
    SXR=voxSize[0]; SYR=voxSize[1]; SZR=voxSize[2];
    //mexPrintf("voxSizeR: %f x %f x %f\n", SXR, SYR, SZR);

    if ((myarray = mxGetField(img, movIdx, "voxelSize"))==NULL) mexErrMsgTxt("Voxel size dimmension of the moving image is not defined!");
    voxSizeDim = mxGetNumberOfElements(myarray);
    if (voxSizeDim!=3) mexErrMsgTxt("Invalid voxel size dimmension of moving img, must be 3!");
    if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the moving img voxelSize, must be single!");
    voxSize = (float*)mxGetData(myarray);
    SXO=voxSize[0]; SYO=voxSize[1]; SZO=voxSize[2];
    //mexPrintf("voxSizeO: %f x %f x %f\n", SXO, SYO, SZO);

    // O- origin ----------------------------------------------------------
    float *O;
    myarray = mxGetField(img, refIdx, "O");
    if (myarray==NULL) { // origin is (0,0,0)
        OXR=0; OYR=0; OZR=0;
    }
    else {
        size_t dim = mxGetNumberOfElements(myarray);
        if (dim!=3) mexErrMsgTxt("Invalid origin dimmension of ref. img, must be 3!");
        if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the ref img origin (O), must be single!");
        O = (float*)mxGetData(myarray);
        OXR=O[0]; OYR=O[1]; OZR=O[2];
    }
    //mexPrintf("Reference origin: %f x %f x %f\n", OXR, OYR, OZR);

    myarray = mxGetField(img, movIdx, "O");
    if (myarray==NULL) { // origin is (0,0,0)
        OXO=0; OYO=0; OZO=0;
    }
    else {
        size_t dim = mxGetNumberOfElements(myarray);
        if (dim!=3) mexErrMsgTxt("Invalid origin dimmension of moving img, must be 3!");
        if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the moving img origin (O), must be single!");
        O = (float*)mxGetData(myarray);
        OXO=O[0]; OYO=O[1]; OZO=O[2];
    }
    //mexPrintf("Moving image origin: %f x %f x %f\n", OXO, OYO, OZO);

    // data - pointers and image size (in voxels) -------------------------
    if ((myarray = mxGetField(img, refIdx, "data"))==NULL) mexErrMsgTxt("Image data of ref. img is not defined!");
    if (!mxIsUint8(myarray)) mexErrMsgTxt("Invalid data type of the ref. img data, must be uint8!");
    const mwSize *dataSize = mxGetDimensions(myarray);
    NXR=dataSize[0]; NYR=dataSize[1]; NZR=dataSize[2];
    NXYR=NXR*NYR; NXYZR=NXYR*NZR;
    //mexPrintf("Ref data size: %d x %d x %d\n", NXR, NYR, NZR);
    pMR0 = (uint8_t*)mxGetData(myarray);
    //mexPrintf("initial ref data : %d x %d x %d\n", pMR0[0], pMR0[1], pMR0[2]);

    if ((myarray = mxGetField(img, movIdx, "data"))==NULL) mexErrMsgTxt("Image data of moving img is not defined!");
    if (!mxIsUint8(myarray)) mexErrMsgTxt("Invalid data type of the moving img data, must be uint8!");
    const mwSize *ImdataSize = mxGetDimensions(myarray);
    NXO=ImdataSize[0]; NYO=ImdataSize[1]; NZO=ImdataSize[2];
    NXYZO=NXO*NYO*NZO;
    //mexPrintf("Moving img data size: %d x %d x %d\n", NXO, NYO, NZO);
    //  NOT NEEDED  // pMO0 = (uint8_t*)mxGetData(myarray);
    //mexPrintf("initial moving data : %d x %d x %d\n", pMO[0], pMO[1], pMO[2]);

    // T - transformation of the moving image -----------------------------
    if ((myarray = mxGetField(img, movIdx, "T"))==NULL) {
        Transf=false;
    } else {
        dataSize = mxGetDimensions(myarray);
        if (dataSize[0]!=4 || dataSize[1]!=4) {
            if (mxGetNumberOfElements(myarray))
                mexErrMsgTxt("Invalid transformation T of moving img, must be 4x4");
            else {
                Transf=false;
            }
        }
        else {
            if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the moving img T, must be single!");
            pT=(float*)mxGetData(myarray);
            Transf=true;
        }
    }

    // D - deformation field of the moving image --------------------------
    if ((myarray = mxGetField(img, movIdx, "D"))==NULL) {
        Deform=false;
    } else {
        if (mxGetNumberOfElements(myarray)) {
            dataSize = mxGetDimensions(myarray);
            if (dataSize[0]!=NXR || dataSize[1]!=NYR || dataSize[2]!=NZR) {
                mexPrintf("Invalid size of the deformation field D: %d, %d, %d\n", dataSize[0], dataSize[1], dataSize[2] );
                Deform=false;
            } else {
                if (!mxIsSingle(myarray)) mexErrMsgTxt("Invalid data type of the moving img deformation field (D), must be single!");
                pDXO=(float*)mxGetData(myarray);
                pDYO= pDXO+NXYZO;
                pDZO= pDYO+NXYZO;
                Deform=true;
            }
        } else {
            Deform=false;
        }
    }

    // T and D of the reference image--------------------------------------
    if ((myarray = mxGetField(img, refIdx, "T"))!=NULL) {
        if (mxGetNumberOfElements(myarray)) {
            mexErrMsgTxt("The reference image must not be tronsformedand (T)!\n");
        }
    }

    // D - deformation field of the moving image --------------------------
    if ((myarray = mxGetField(img, movIdx, "D"))==NULL) {
        if (mxGetNumberOfElements(myarray)) {
            mexErrMsgTxt("The reference image must not be deformed (D)!\n");
        }
    }



    //=====================================================================

    //define the output data

    // define a new matrix RRdata (resampled reference data)
    //mxCreateDoubleMatrix initializes each element in the pr array to 0

    //mxArray *mxCreateNumericArray(mwSize ndim, const mwSize *dims, mxClassID classid, mxComplexity ComplexFlag);
    plhs[0] = mxCreateNumericArray(3,ImdataSize,mxUINT8_CLASS,mxREAL);
    uint8_t *pRez=(uint8_t*)mxGetData(plhs[0]); //RRdata



    //=====================================================================
    // computation part
    // ====================================================================

  float x0,y0,z0,xD,yD,zD, x1,y1,z1;
  int X1,Y1,Z1;
  float tmpRez;
  for (int pz=0;pz<NZO;pz++){
    for (int py=0;py<NYO;py++){
      for (int px=0;px<NXO;px++){
        x0=px*SXO-OXO;
        y0=py*SYO-OYO;
        z0=pz*SZO-OZO;
        if (Deform){
          xD=x0+*pDXO; pDXO++;
          yD=y0+*pDYO; pDYO++;
          zD=z0+*pDZO; pDZO++;
        }
        else {
          xD=x0;  yD=y0;  zD=z0;
        }
        if (Transf){
          x0=xD; y0=yD; z0=zD;
          pTtmp=pT;
          xD=  x0**pTtmp; pTtmp++;
          yD=  x0**pTtmp; pTtmp++;
          zD=  x0**pTtmp; pTtmp++;
          pTtmp++;
          xD+= y0**pTtmp; pTtmp++;
          yD+= y0**pTtmp; pTtmp++;
          zD+= y0**pTtmp; pTtmp++;
          pTtmp++;
          xD+= z0**pTtmp; pTtmp++;
          yD+= z0**pTtmp; pTtmp++;
          zD+= z0**pTtmp; pTtmp++;
          pTtmp++;
          xD+=   *pTtmp; pTtmp++;
          yD+=   *pTtmp; pTtmp++;
          zD+=   *pTtmp;
        }
        // xD,yD,zD are now positions in mm.
        x0=(xD+OXR)/SXR;
        y0=(yD+OYR)/SYR;
        z0=(zD+OZR)/SZR;
        // x0,y0,z0 are now postitions in Ref image in voxels
        X1=floor(x0);
        Y1=floor(y0);
        Z1=floor(z0);

        if ((X1>=0)&&(Y1>=0)&&(Z1>=0)&&(X1<NXR-1)&&(Y1<NYR-1)&&(Z1<NZR-1)){
          pMR=pMR0 + X1 + NXR*(Y1 + NYR * Z1); //ImRef.Data.GetPointer(X1,Y1,Z1); //pImRef

          x1=x0-X1; y1=y0-Y1; z1=z0-Z1;

          tmpRez=  (1-x1)*(1-y1)*(1-z1) * *(pMR           ) ;
          tmpRez+=   x1  *(1-y1)*(1-z1) * *(pMR+1         ) ;
          tmpRez+= (1-x1)*  y1  *(1-z1) * *(pMR  +NXR     ) ;
          tmpRez+=   x1  *  y1  *(1-z1) * *(pMR+1+NXR     ) ;
          tmpRez+= (1-x1)*(1-y1)*  z1   * *(pMR      +NXYR) ;
          tmpRez+=   x1  *(1-y1)*  z1   * *(pMR+1    +NXYR) ;
          tmpRez+= (1-x1)*  y1  *  z1   * *(pMR  +NXR+NXYR) ;
          tmpRez+=   x1  *  y1  *  z1   * *(pMR+1+NXR+NXYR) ;

          tmpRez+=0.5;
          tmpRez=std::min(float(255.0),tmpRez); tmpRez=std::max(float(0.0),tmpRez);
          *pRez=(uint8_t) tmpRez;
        }
        else *pRez=0;

        pRez++;
      } //px
    } //py
  } //pz

  //return Rez;
}
