#include <math.h>
//#include <matrix.h> //PRJ 2017-05-05
#include <mex.h>

//-------------
#include <iostream>
#include <stdint.h>
#include <cstring>
//#include "mexcpp.h"  //see https://github.com/kuitang/mexcpp
//using namespace mexcpp;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Input parameters:
        - control grid
        - displacement matrix (by reference)
        Return:
        - the modified displacement matrix (as a reference)
        - no LHS parameters.
    */
    if (nrhs!=2) 
        mexErrMsgTxt("Required input paremeters: CG structure, D (image deformation field)!");
    if(!mxIsStruct(prhs[0]))
        mexErrMsgTxt("First input parameter must be a structure!");
    
    //StructMat sm(prhs[0]);
    
    mxArray *gridArray;
    //mxArray *dispArray = prhs[1];
    mxArray *stepArray;
    mxArray *marginArray;
    mxArray *kernelxArray;
    mxArray *kernelyArray;
    mxArray *kernelzArray;
   
    //mexPrintf("...reading input parameters\n");
  
    if ((gridArray = mxGetField(prhs[0], 0, "grid"))==NULL) mexErrMsgTxt("Invalid CG structure, missing the grid!");
    if (!mxIsSingle(gridArray)) mexErrMsgTxt("Invalid data type of the grid matrix, must be single!");
    
    //if ((dispArray = mxGetField(prhs[1],0, "displacement"))==NULL) mexErrMsgTxt("Invalid displacement field, missing the displacement!");
    
    if ((stepArray = mxGetField(prhs[0], 0, "step"))==NULL) mexErrMsgTxt("Invalid step field, missing the step!");
    if (!mxIsInt32(stepArray)) mexErrMsgTxt("Invalid data type of the step, must be int32!");
    
    if ((marginArray = mxGetField(prhs[0], 0, "margin"))==NULL) mexErrMsgTxt("Invalid margin field, missing the margin!");
    if (!mxIsInt32(marginArray)) mexErrMsgTxt("Invalid data type of the maring, must be int32!");
    
    if ((kernelxArray = mxGetField(prhs[0], 0, "kernelx"))==NULL) mexErrMsgTxt("Invalid kernelx field, missing the kernelx!");
    if (!mxIsSingle(kernelxArray)) mexErrMsgTxt("Invalid data type of kernelx, must be single!");
    
    if ((kernelyArray = mxGetField(prhs[0], 0, "kernely"))==NULL) mexErrMsgTxt("Invalid kernely field, missing the kernely!");
    if (!mxIsSingle(kernelyArray)) mexErrMsgTxt("Invalid data type of kernely, must be single!");
    
    if ((kernelzArray = mxGetField(prhs[0], 0, "kernelz"))==NULL) mexErrMsgTxt("Invalid kernelz field, missing the kernelz!");
    if (!mxIsSingle(kernelzArray)) mexErrMsgTxt("Invalid data type of kernelz, must be single!");
      
    //mexPrintf("...getting pointers\n");
    
    // const mwSize *dim_grid = mxGetDimensions(gridArray);
    
    float *grid=(float*)mxGetData(gridArray);
    
    int *step=(int*)mxGetData(stepArray);
    
    int *margin=(int*)mxGetData(marginArray);
   
    float *kernelx=(float*)mxGetData(kernelxArray);
    int kernelxsize=mxGetNumberOfElements(kernelxArray);
    int kernelxshift=(kernelxsize-1)/2;
    
    float *kernely=(float*)mxGetData(kernelyArray);
    int kernelysize=mxGetNumberOfElements(kernelyArray);
    int kernelyshift=(kernelysize-1)/2;
    
    float *kernelz=(float*)mxGetData(kernelzArray);
    int kernelzsize=mxGetNumberOfElements(kernelzArray);
    int kernelzshift=(kernelzsize-1)/2;
    
    //mexPrintf("kernel size\n");
    //mexPrintf("%d %d %d\n",kernelxsize, kernelysize, kernelzsize);
    
    if (!mxIsSingle(prhs[1])) mexErrMsgTxt("Invalid data type of disp, must be single!");
    float *disp =(float*)mxGetData(prhs[1]);
   
    //get the dimensions of the displacement matrix
    int disp_dims      = (int)mxGetNumberOfDimensions(prhs[1]);
    const mwSize *dim_disp  = mxGetDimensions(prhs[1]);
    int  x_disp_dim         = dim_disp[0];
    int  y_disp_dim         = dim_disp[1];
    int  z_disp_dim         = dim_disp[2];
    int  xy_disp_dim  = x_disp_dim*y_disp_dim;
    int  xyz_disp_dim = xy_disp_dim*z_disp_dim;
    int  numel_disp = mxGetNumberOfElements(prhs[1]) ; //xyz_disp_dim*3;
    //mexPrintf("displacement dimensions\n");
    //mexPrintf("%d %d %d %d\n",disp_dims,x_disp_dim, y_disp_dim, z_disp_dim);
    
    //get the dimensions of the grid matrix
    int grid_dims      = (int)mxGetNumberOfDimensions(gridArray);
    const mwSize *dim_grid  = mxGetDimensions(gridArray);
    int  x_grid_dim         = dim_grid[0];
    int  y_grid_dim         = dim_grid[1];
    int  z_grid_dim         = dim_grid[2];
    int xyz_grid_dim = x_grid_dim * y_grid_dim * z_grid_dim;
    int numel_grid = mxGetNumberOfElements(gridArray) ; //xyz_grid_dim*3;
    //mexPrintf("grid dimensions\n");
    //mexPrintf("%d %d %d %d, total elements: %d\n",x_grid_dim, y_grid_dim, z_grid_dim,  dim_grid[3], numel_grid);
    
   
    /* processing using separable kernel first in x direction, later in y and z */
    // step 1: processing of CGx.CGy.CGz -> DisplX.CGy.CGz
    int numel_gridX=x_disp_dim*y_grid_dim*z_grid_dim*3;
    float *gridX = (float*) malloc (numel_gridX*sizeof(float));
    if (gridX==NULL) mexErrMsgTxt("Unable to allocate memory (gridX)!");

    int numel_wX=x_disp_dim*y_grid_dim*z_grid_dim;
    float *wX = (float*) malloc (numel_gridX*sizeof(float));
    if (gridX==NULL) mexErrMsgTxt("Unable to allocate memory (wX)!");

    float *gridX0, *gridX1, *gridX2, *wX0;
    // init temporary fild gridX to 0
    memset (gridX,0,numel_gridX*sizeof(float));
    //gridX0=gridX;
    //for (int i = 0; i<numel_gridX; i++) {
    //    *gridX0=0;
    //    gridX0++;
    //}
    memset (wX,0,numel_wX*sizeof(float));
    //wX0=wX;
    //for (int i = 0; i<numel_wX; i++) {
    //    *wX0=0;
    //    wX0++;
    //}

    float *xforce, *yforce, *zforce, *pkernel;
    xforce = grid;
    yforce = xforce + xyz_grid_dim;
    zforce = yforce + xyz_grid_dim;
    
    // inrepolate in X with kernelx    
    for(int z=0;z<z_grid_dim;z++){
        for(int y=0;y<y_grid_dim;y++){
            int cgx = -margin[0];
            for(int x=0;x<x_grid_dim;x++){
                
                gridX0=gridX + cgx - kernelxshift + x_disp_dim*y + x_disp_dim*y_grid_dim*z;
                gridX1=gridX0 + x_disp_dim*y_grid_dim*z_grid_dim;
                gridX2=gridX1 + x_disp_dim*y_grid_dim*z_grid_dim;

                wX0=wX + cgx - kernelxshift + x_disp_dim*y + x_disp_dim*y_grid_dim*z;
              
                pkernel=kernelx;
                for(int dx=-kernelxshift;dx<=kernelxshift;dx++){ 
                    if(cgx+dx>=0 && cgx+dx<x_disp_dim){
                        *gridX0 += *xforce**pkernel;
                        *gridX1 += *yforce**pkernel;
                        *gridX2 += *zforce**pkernel;
                        *wX0 += *pkernel;
                    }
                    pkernel++;
                    gridX0++;
                    gridX1++;
                    gridX2++;
                    wX0++;
                }
                cgx+=step[0];
                xforce++;
                yforce++;
                zforce++;
            }
        }
    }
    gridX0=gridX;
    for (int dim=0; dim<3; dim++) {
        wX0=wX;
        for (int i = 0; i<numel_wX; i++) {
            if (*wX0>0)
                *gridX0/=*wX0;
            gridX0++;
            wX0++;
        }
    }

            
    // step 2: processing of DisplX.CGy.CGz -> DisplX.DisplY.CGz
    int numel_gridXY=x_disp_dim*y_disp_dim*z_grid_dim*3;
    float *gridXY = (float*) malloc (numel_gridXY*sizeof(float));
    if (gridXY==NULL) mexErrMsgTxt("Unable to allocate memory (gridXY)!");

    int numel_wXY=x_disp_dim*y_disp_dim*z_grid_dim;
    float *wXY = (float*) malloc (numel_wXY*sizeof(float));
    if (wXY==NULL) mexErrMsgTxt("Unable to allocate memory (wXY)!");
    float *gridXY0, *gridXY1, *gridXY2, *wXY0;
    // init temporary fild gridXY to 0
    memset (gridXY,0,numel_gridXY*sizeof(float));
    //gridXY0=gridXY;
    //for (int i = 0; i<numel_gridXY; i++) {
    //    *gridXY0=0;
    //    gridXY0++;
    //}
    memset (wXY,0,numel_wXY*sizeof(float));
    //wXY0=wXY;
    //for (int i = 0; i<numel_wXY; i++) {
    //    *wXY0=0;
    //    wXY0++;
    //}

    xforce = gridX;
    yforce = xforce + x_disp_dim*y_grid_dim*z_grid_dim;
    zforce = yforce + x_disp_dim*y_grid_dim*z_grid_dim;
    
    // inrepolate in Y with kernely
    for(int z=0;z<z_grid_dim;z++){
        int cgy = -margin[1];
        for(int y=0;y<y_grid_dim;y++){
            for(int x=0;x<x_disp_dim;x++){
                             
                gridXY0=gridXY +x + x_disp_dim*(cgy-kernelyshift) + xy_disp_dim*z;
                gridXY1=gridXY0 + x_disp_dim*y_disp_dim*z_grid_dim;
                gridXY2=gridXY1 + x_disp_dim*y_disp_dim*z_grid_dim;

                wXY0=wXY +x + x_disp_dim*(cgy-kernelyshift) + xy_disp_dim*z;
              
                pkernel=kernely;
                for(int dy=-kernelyshift;dy<=kernelyshift;dy++){ 
                    if(cgy+dy>=0 && cgy+dy<y_disp_dim){
                        *gridXY0 += *xforce**pkernel;
                        *gridXY1 += *yforce**pkernel;
                        *gridXY2 += *zforce**pkernel;
                        *wXY0 += *pkernel;
                    }
                    pkernel++;
                    gridXY0+=x_disp_dim;
                    gridXY1+=x_disp_dim;
                    gridXY2+=x_disp_dim;
                    wXY0+=x_disp_dim;
                }                
                xforce++;
                yforce++;
                zforce++;
            }
            cgy+=step[1];
        }
    }

    gridXY0=gridXY;
    for (int dim=0; dim<3; dim++) {
        wXY0=wXY;
        for (int i = 0; i<numel_wXY; i++) {
            if (*wXY0>0)
                *gridXY0/=*wXY0;
            gridXY0++;
            wXY0++;
        }
    }

      
    // step 3: processing of DisplX.DisplY.CGz -> DisplX.DisplY.DisplZ
    //float *.... // save the result into grid array
    
    float *wXYZ = (float*) malloc (xyz_disp_dim*sizeof(float));
    if (wXYZ==NULL) mexErrMsgTxt("Unable to allocate memory (wXYZ)!");
    float *disp0, *disp1, *disp2, *wXYZ0;
    // init displacement fild to 0
    memset (disp,0,numel_disp*sizeof(float));
    //disp0 = disp;
    //for(int i=0;i<numel_disp;i++){
    //    *disp0=0;
    //    disp0++;
    //}
    memset (wXYZ,0,xyz_disp_dim*sizeof(float));
    //wXYZ0 = wXYZ;
    //for(int i=0;i<xyz_disp_dim;i++){
    //    *wXYZ0=0;
    //    wXYZ0++;
    //}

    xforce = gridXY;
    yforce = xforce + xy_disp_dim*z_grid_dim;
    zforce = yforce + xy_disp_dim*z_grid_dim;
    
    // inrepolate in Z with kernelz
    int cgz = -margin[2];
    for(int z=0;z<z_grid_dim;z++){
        for(int y=0;y<y_disp_dim;y++){
            for(int x=0;x<x_disp_dim;x++){
                             
                disp0=disp +x + x_disp_dim*y + xy_disp_dim*(cgz-kernelzshift);
                disp1=disp0 + xyz_disp_dim;
                disp2=disp1 + xyz_disp_dim;

                wXYZ0=wXYZ +x + x_disp_dim*y + xy_disp_dim*(cgz-kernelzshift);
              
                pkernel=kernelz;
                for(int dz=-kernelzshift;dz<=kernelzshift;dz++){ 
                    if(cgz+dz>=0 && cgz+dz<z_disp_dim){
                        *disp0 += *xforce**pkernel;
                        *disp1 += *yforce**pkernel;
                        *disp2 += *zforce**pkernel;
                        *wXYZ0 += *pkernel;
                    }
                    pkernel++;
                    disp0+=xy_disp_dim;
                    disp1+=xy_disp_dim;
                    disp2+=xy_disp_dim;
                    wXYZ0+=xy_disp_dim;
                }                
                xforce++;
                yforce++;
                zforce++;
            }
        }
        cgz+=step[2];
    }

    disp0 = disp;
    for (int dim=0; dim<3; dim++) {
        wXYZ0 = wXYZ;
        for(int i=0;i<xyz_disp_dim;i++){
            if (*wXYZ0>0)
                *disp0/=*wXYZ0;
            disp0++;
            wXYZ0++;
        }
    }
    
    // free the buffers:
    free (gridX);
    free (gridXY);
    free (wX);
    free (wXY);
    free (wXYZ);
    //mexPrintf("end\n");
}
