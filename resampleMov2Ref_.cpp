/* Author: Peter Rogelj <peter.rogelj@upr.si> */

#include <math.h>
//#include <matrix.h> //PRJ 2017-05-05
#include <mex.h>

//-------------
#include <iostream>
#include <stdint.h>
#include "mexcpp.h"  //see https://github.com/kuitang/mexcpp
using namespace mexcpp;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Description: Resample the (optionally trensformed/deformed) moving image to the space of the reference image.
       The resulting image has the same dimmension,voxel size and origin as the reference image.
       The output result is only the img.data field!

       NOTE: the forward, not reverse, interpolation method is used. Consequently there holes may appear in the resampled image in case of:
             - higher resolution of the referenc eimage
             - intense deformation of the moving image
       This (forward) interpolation method is slower and less than reverse interpolation method and more approximate, tgerefore,
       WE STRONGLY RECOMMEND TO RATHER USE 'resampleRef2Mov' FOR COMPUTATIONAL PURPOSES. THIS FUNCTION 'resampleMov2Ref_' IS MEANT FOR VISUALIZATION PURPOSES ONLY!

       Input parameters:
        REG structure with images loaded
       Return:
        resampled data of the moving image (the img.data matrix)
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
    uint8_t *pMO; //, *pMO0;

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
    const mwSize *RdataSize = mxGetDimensions(myarray);
    NXR=RdataSize[0]; NYR=RdataSize[1]; NZR=RdataSize[2];
    NXYR=NXR*NYR; NXYZR=NXYR*NZR;
    //mexPrintf("Ref data size: %d x %d x %d\n", NXR, NYR, NZR);
    // NOT NEEDED // pMR0 = (uint8_t*)mxGetData(myarray);
    //mexPrintf("initial ref data : %d x %d x %d\n", pMR0[0], pMR0[1], pMR0[2]);

    if ((myarray = mxGetField(img, movIdx, "data"))==NULL) mexErrMsgTxt("Image data of moving img is not defined!");
    if (!mxIsUint8(myarray)) mexErrMsgTxt("Invalid data type of the moving img data, must be uint8!");
    const mwSize *dataSize = mxGetDimensions(myarray);
    NXO=dataSize[0]; NYO=dataSize[1]; NZO=dataSize[2];
    NXYZO=NXO*NYO*NZO;
    //mexPrintf("Moving img data size: %d x %d x %d\n", NXO, NYO, NZO);
    pMO = (uint8_t*)mxGetData(myarray);
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

    // define a new matrix RMdata (resampled moving data)
    //mxCreateDoubleMatrix initializes each element in the pr array to 0

    //mxArray *mxCreateNumericArray(mwSize ndim, const mwSize *dims, mxClassID classid, mxComplexity ComplexFlag);
    plhs[0] = mxCreateNumericArray(3,RdataSize,mxUINT8_CLASS,mxREAL);
    uint8_t *pRez0=(uint8_t*)mxGetData(plhs[0]); //RMdata



    //=====================================================================
    // computation part
    // ====================================================================

  //allocate temporary fields TData and Weight
  float *pTData,*pWeight, *pTData0,*pWeight0;
  pTData0 = (float*) mxCalloc(NXYZR, sizeof(float));
  pWeight0 = (float*) mxCalloc(NXYZR, sizeof(float));


  float x0,y0,z0,xD,yD,zD, x1,y1,z1;
  int X1,Y1,Z1;
  float tmpRez;

  //over pMO
  float W;
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

        // if ((X1>=0)&&(Y1>=0)&&(Z1>=0)&&(X1<NXR-1)&&(Y1<NYR-1)&&(Z1<NZR-1)){   // removed to correctly increase pMO

        x1=x0-X1; y1=y0-Y1; z1=z0-Z1;

        pTData = pTData0 + X1 + NXR*(Y1 + NYR * Z1);
        pWeight = pWeight0 + X1 + NXR*(Y1 + NYR * Z1);


        bool bx= ((X1>=0)&&(X1<NXR));
        bool bx1=((X1+1>=0)&&(X1+1<NXR));
        bool by= ((Y1>=0)&&(Y1<NYR));
        bool by1=((Y1+1>=0)&&(Y1+1<NYR));
        bool bz= ((Z1>=0)&&(Z1<NZR));
        bool bz1=((Z1+1>=0)&&(Z1+1<NZR));

        if ( bx && by && bz){
          W=(1-x1)*(1-y1)*(1-z1);
          *(pTData)+=*pMO*W;
          *(pWeight)+=W;
        }
        if ( bx1 && by && bz){
          W=(x1)*(1-y1)*(1-z1);
          *(pTData+1)+=*pMO*W;
          *(pWeight+1)+=W;
        }
        if ( bx && by1 && bz){
          W=(1-x1)*(y1)*(1-z1);
          *(pTData+NXR)+=*pMO*W;
          *(pWeight+NXR)+=W;
        }
        if ( bx1 && by1 && bz){
          W=(x1)*(y1)*(1-z1);
          *(pTData+1+NXR)+=*pMO*W;
          *(pWeight+1+NXR)+=W;
        }
        if ( bx && by && bz1){
          W=(1-x1)*(1-y1)*(z1);
          *(pTData+NXYR)+=*pMO*W;
          *(pWeight+NXYR)+=W;
        }
        if ( bx1 && by && bz1){
          W=(x1)*(1-y1)*(z1);
          *(pTData+1+NXYR)+=*pMO*W;
          *(pWeight+1+NXYR)+=W;
        }
        if ( bx && by1 && bz1){
          W=(1-x1)*(y1)*(z1);
          *(pTData+NXR+NXYR)+=*pMO*W;
          *(pWeight+NXR+NXYR)+=W;
        }
        if ( bx1 && by1 && bz1){
          W=(x1)*(y1)*(z1);
          *(pTData+1+NXR+NXYR)+=*pMO*W;
          *(pWeight+1+NXR+NXYR)+=W;
        }
        pMO++;

      } //px
    } //py
  } //pz

  // devide sum of intensities and weights
  pTData = pTData0;
  pWeight = pWeight0;
  uint8_t *pRez = pRez0;
  int tmp;
  for (int pz=0;pz<NZR;pz++){
    for (int py=0;py<NYR;py++){
      for (int px=0;px<NXR;px++){
        if (*pWeight>0){
          *pRez=(*pTData)/(*pWeight);
        }
        else {
          *pRez=0;                  // could be estimated from neighbours
        }
        pRez++; pTData++; pWeight++;
      }
    }
  }

  // fill up the holes... or not?
  bool repeat=true;
  //int NFillHoles=3; //just a setting to fill holes from 5 pix distant voxels
  //define NFillHoles fron the voxel sizes: maxOvoxSize / minRvoxSize
  float SRatio=std::max(SXO, std::max(SYO,SZO)) / std::min(SXR, std::min(SYR, SZR));

  for (int rp=0;(rp<SRatio)&&(repeat);rp++){    //SRatio = NFillHoles
   pWeight = pWeight0;
   pRez = pRez0;
   for (int pz=0;pz<NZR;pz++){
    for (int py=0;py<NYR;py++){
      for (int px=0;px<NXR;px++){
        if (*pWeight==0){
          float tmpV=0;
          if (px>0){
            *pWeight+=*(pWeight-1);
            tmpV+=*(pRez-1)**(pWeight-1);
          }
          if (px<NXR-1) {
            *pWeight+=*(pWeight+1);
            tmpV+=*(pRez+1)**(pWeight+1);
          }
          if (py>0) {
            *pWeight+=*(pWeight-NXR);
            tmpV+=*(pRez-NXR)**(pWeight-NXR);
          }
          if (py<NYR-1) {
            *pWeight+=*(pWeight+NXR);
            tmpV+=*(pRez+NXR)**(pWeight+NXR);
          }
          if (pz>0) {
            *pWeight+=*(pWeight-NXYR);
            tmpV+=*(pRez-NXYR)**(pWeight-NXYR);
          }
          if (pz<NZR-1) {
            *pWeight+=*(pWeight+NXYR);
            tmpV+=*(pRez+NXYR)**(pWeight+NXYR);
          }
          if (*pWeight>0) {
            tmpV/=*pWeight;
            if (tmpV>255) tmpV=255;
            if (tmpV<0) tmpV=0;
            *pRez=tmpV;
            *pWeight=*pWeight/1000;
          }
          else repeat=true;
        }
        pRez++; pWeight++;
      }//z
    } //y
   } //x
  }// rp

  mxFree(pTData0);
  mxFree(pWeight0);

  //return Rez;
}
