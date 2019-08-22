#include <math.h>
#include <mex.h>

//-------------
#include <iostream>
#include <stdint.h>
//#include "mexcpp.h"  //see https://github.com/kuitang/mexcpp
//using namespace mexcpp;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* modifyDisplacement( cg, cgIndex, cgDelta, D0, D1 );
     *
     * A function modifyDisplacements modify image displacements D0 created by B-spline control grid cg
     * such that an additional change of a single control grid parameter defined by control point index cgIndex
     * is performed, modifying the parameter for a value cgDelta. This modifies the provided displacement field D0
     * considering the parameter change into a new displacement field D1.      *
     *
     Input parameters:
     - control grid
     - control point index
     - delta (change of the cg parameter value)
     - input  displacement field
     - output displacement field

     Return: NONE

     Result: the udpated output displacement field
     */
    if (nrhs!=5)
        mexErrMsgTxt("Required input paremeters: CG structure, CG index, delta value, D0 (initial image deformation field), D1 new deformation field!");
    if(!mxIsStruct(prhs[0]))
        mexErrMsgTxt("First input parameter must be a structure!");
    
    
    // === CG structure ===============================================================================
    mxArray *gridArray;
    if ((gridArray = mxGetField(prhs[0], 0, "grid"))==NULL) mexErrMsgTxt("Invalid CG structure, missing the grid!");
    if (!mxIsSingle(gridArray)) mexErrMsgTxt("Invalid data type of the grid matrix, must be single!");
    if ( mxGetNumberOfDimensions(gridArray) != 4) mexErrMsgTxt("Invalid size of the igrid array cg.grid, should have 4 dimensions!");
    const int *dim_grid  = (const int*)mxGetDimensions(gridArray);
    int  NCGX = dim_grid[0];
    int  NCGY = dim_grid[1];
    int  NCGZ = dim_grid[2];
    int  NCGXY = NCGX*NCGY;
    int  NCGXYZ= NCGXY*NCGZ;
    //mexPrintf("CG size: %d %d %d \n", NCGX, NCGY, NCGZ);

    mxArray *marginArray;
    if ((marginArray = mxGetField(prhs[0], 0, "margin"))==NULL) mexErrMsgTxt("Invalid margin field, missing the margin!");
    if (!mxIsInt32(marginArray)) mexErrMsgTxt("Invalid data type of the maring, must be int32!");
    int *margin=(int*)mxGetData(marginArray);
    //mexPrintf("margin: %d %d %d \n", margin[0],  margin[1],  margin[2]);
    
    mxArray *stepArray;
    if ((stepArray = mxGetField(prhs[0], 0, "step"))==NULL) mexErrMsgTxt("Invalid step field, missing the step!");
    if (!mxIsInt32(stepArray)) mexErrMsgTxt("Invalid data type of the step, must be int32!");
    int *step=(int*)mxGetData(stepArray);
    //mexPrintf("step: %d %d %d \n", step[0],  step[1],  step[2]);

    mxArray *kernel3DArray;
    if ((kernel3DArray = mxGetField(prhs[0], 0, "kernel3D"))==NULL) mexErrMsgTxt("Invalid kernelx field, missing the kernel3D!");
    if (!mxIsSingle(kernel3DArray)) mexErrMsgTxt("Invalid data type of kernel3D, must be single!");
    float *pK=(float*)mxGetData(kernel3DArray);
    size_t kernel3DDims = mxGetNumberOfDimensions(kernel3DArray);
    if (kernel3DDims!=3) mexErrMsgTxt("Invalid kernel3D size, should have three dimmensions!");
    const int *kernel3D_dims  = (const int*)mxGetDimensions(kernel3DArray);
    int kernelxshift=(kernel3D_dims[0]-1)/2;
    int kernelyshift=(kernel3D_dims[1]-1)/2;
    int kernelzshift=(kernel3D_dims[2]-1)/2;
    //mexPrintf("Kernel size: %d %d %d\n",kernel3D_dims[0], kernel3D_dims[1], kernel3D_dims[2]);
    //mexPrintf("Kernel center value: %f\n",*(pK + kernelxshift + kernel3D_dims[0]*kernelyshift  + kernel3D_dims[0]*kernel3D_dims[1]*kernelzshift ));
         
    // === CG index ===============================================================================
    int x,y,z,t;
    if (!mxIsInt32(prhs[1])) mexErrMsgTxt("Invalid data type of Control grid index, must be int32!");
    int *cgIndex =(int*)mxGetData(prhs[1]);
    int index=*cgIndex-1;
    switch( mxGetNumberOfElements(prhs[1]) ) {
        case 4 :
            x = cgIndex[0]-1; //counting in Matlab starts with 1!
            y = cgIndex[1]-1;
            z = cgIndex[2]-1;
            t = cgIndex[3]-1;
             break;
       case 1 :
            t = (int) floor(index / NCGXYZ);
            index = index % NCGXYZ; /* Likely uses the result of the division. */
            z=  (int) floor(index / NCGXY);
            index = index % NCGXY;
            y=  (int) floor(index / NCGX);
            x = index % NCGX;
            break;
       default :
            mexErrMsgTxt("Invalid size of control grid index, should have 4 or 1 elements!");
            return;
    }
    //mexPrintf("index xyzt: %d %d %d %d\n",x,y,z,t);

    // === cg delta ===============================================================================
    if (!mxIsSingle(prhs[2])) mexErrMsgTxt("Invalid data type of the cgDelta value, must be single!");
    if ( mxGetNumberOfElements(prhs[2]) != 1) mexErrMsgTxt("Parameter cgDelta must be a scalar!");
    float *pcgDelta = (float*)mxGetData(prhs[2]);
    float cgDelta = *pcgDelta;
    //mexPrintf("cgDelta: %f\n",cgDelta);

    // === initial D0 ===============================================================================
    if (!mxIsSingle(prhs[3])) mexErrMsgTxt("Invalid data type of the image displacement field D0, must be single!");
    float *pD0 =(float*)mxGetData(prhs[3]);
    if ( mxGetNumberOfDimensions(prhs[3]) != 4) mexErrMsgTxt("Invalid size of the image displacement field D0, should have 4 dimensions!");
    int NX, NY, NZ, NXY, NXYZ;
    const int *D0dim  = (const int*)mxGetDimensions(prhs[3]);
    if (D0dim[3] != 3)  mexErrMsgTxt("Invalid size of the image displacement field D0, 4 dimension should have size 3!");
    NX = D0dim[0]; NY = D0dim[1]; NZ = D0dim[2];
    NXY=NX*NY; NXYZ=NXY*NZ;

    // === resulting D1 ===============================================================================
    if (!mxIsSingle(prhs[4])) mexErrMsgTxt("Invalid data type of the resulting displacement field D1, must be single!");
    float *pD1 =(float*)mxGetData(prhs[4]);
    if ( mxGetNumberOfDimensions(prhs[4]) != 4) mexErrMsgTxt("Invalid size of the resulting displacement field D1, should have 4 dimensions!");
    const int *D1dim  = (const int*)mxGetDimensions(prhs[4]);
    if (D1dim[3] != 3)  mexErrMsgTxt("Invalid size of the resulting displacement field D0, 4 dimension should have size 3!");
    if ( NX!=D1dim[0] ||  NY!=D1dim[1] || NZ!=D1dim[2] )  mexErrMsgTxt("Deformation fields D0 and D1 should have the same size!");

    if (pD0==pD1) mexErrMsgTxt("Both deformation fields share the same memory locations!");

    // ===== COPY D0 to D1 =============================================================================
    float *pD0t=pD0;
    float *pD1t=pD1;
    for (int i=0; i<NXYZ*3; i++) {
        *pD1t=*pD0t;
        pD1t++; pD0t++;
    }

    // compute the position of the control point based on the coordinates of the initial image without margin
    int cgx = x*step[0]-margin[0];
    int cgy = y*step[1]-margin[1];
    int cgz = z*step[2]-margin[2];
       
    pD1t=pD1+NXYZ*t;
    //int num=0; debug

    int ix, iy, iz; // position index of the current voxel
    //get all the voxels that are impacted by this control point
    for(int dz=-kernelzshift;dz<=kernelzshift;dz++){
        iz=cgz+dz;
        float *pD1tz=pD1t+NXY*iz;
        for(int dy=-kernelyshift;dy<=kernelyshift;dy++){
            iy=cgy+dy;
            float *pD1tzy=pD1tz+NX*iy;
            for(int dx=-kernelxshift;dx<=kernelxshift;dx++){
                ix=cgx+dx;
                float *pD1tzyx=pD1tzy+ix;

                //don't compute the displacement for the voxel outside the image (i.e. in the margin)
                if(ix>=0 && iy>=0 && iz>=0 && ix<NX && iy<NY && iz<NZ){
                    *pD1tzyx += *pK * cgDelta;
                    //num++;
                }
                pK++;
            }
        }
    }

    //mexPrintf("num = %d\n", num);
}
