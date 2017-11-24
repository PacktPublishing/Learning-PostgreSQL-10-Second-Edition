#include "postgres.h"
#include "fmgr.h"
#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif
Datum fact(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(fact);
Datum
fact(PG_FUNCTION_ARGS) {
int32 fact = PG_GETARG_INT32(0);
int32 count = 1, result = 1;
for (count = 1; count <= fact; count++)
    result = result * count;
PG_RETURN_INT32(result);
}