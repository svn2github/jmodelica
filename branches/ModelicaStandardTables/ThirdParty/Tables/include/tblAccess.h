#ifndef __TBLACCESS_H__
#define __TBLACCESS_H__

#ifdef TBLXS_DLL
#ifdef TBLXS_EXPORTS
#define TBLXS_API __declspec(dllexport)
#else
#define TBLXS_API __declspec(dllimport)
#endif
#else
#define TBLXS_API extern
#endif

#ifdef __cplusplus

extern "C" {
#endif 

TBLXS_API void*  ModelonTableCreate(const int dimension, const int interpMethod,
                                    const int extrapLwr, const int extrapUpr, 
                                    const int tableType, char* tableName, char* fileName,
                                    const double* tableData, const int* tableSize);
TBLXS_API void   ModelonTableClose(void* object);

TBLXS_API double ModelonTableGetU1(void* object, const int idx);
TBLXS_API double ModelonTableGetU2(void* object, const int idx);
TBLXS_API double ModelonTableGetY(void* object, const int i1, const int i2);
TBLXS_API int    ModelonTableSizeU(void* object);
TBLXS_API int    ModelonTableSizeY(void* object);
TBLXS_API int    ModelonTableCheckScopeU1(void* object, const double u);
TBLXS_API int    ModelonTableCheckScopeU2(void* object, const double u);

TBLXS_API double ModelonTableInterp1(void* object, const int icol, const double u);
TBLXS_API double ModelonTableInterp1Der(void* object, const int icol, const double u,
                                        const double ud);
TBLXS_API double ModelonTableInterp1DerDer(void* object, const int icol, const double u,
                                           const double ud, const double udd);
TBLXS_API double ModelonTableInterp2(void* object, const double u1, const double u2);


#ifdef __cplusplus
}
#endif 

#endif 
