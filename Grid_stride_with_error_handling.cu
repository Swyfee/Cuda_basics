#include <stdio.h>
#include <assert.h>

inline cudaError_t checkCuda(cudaError_t result)
{
  if (result != cudaSuccess) {
    fprintf(stderr, "CUDA Runtime Error: %s\n", cudaGetErrorString(result));
    assert(result == cudaSuccess);
  }
  return result;
}


void init(int *a, int N)
{
  int i;
  for (i = 0; i < N; ++i)
  {
    a[i] = i;
  }
}



__global__
void doubleElements(int *a, int N)
{
  int indexWithinTheGrid;
  indexWithinTheGrid = blockIdx.x * blockDim.x + threadIdx.x;
  int gridStride = gridDim.x * blockDim.x;
  for (int i = indexWithinTheGrid; i < N; i += gridStride)
  {
  if (i < N)
      {
        a[i] *= 2;
      }
  }
}

bool checkElementsAreDoubled(int *a, int N)
{
  int i;
  for (i = 0; i < N; ++i)
  {
    if (a[i] != i*2) return false;
  }
  return true;
}

int main()
{
  /*
   * `N` is greater than the size of the grid (see below).
   */

  int N = 10000;
  int *a;

  size_t size = N * sizeof(int);
  cudaError_t err;
  err =cudaMallocManaged(&a, size);
if (err != cudaSuccess)
{
  printf("Error: %s\n", cudaGetErrorString(err));
}
  
  
  

  init(a, N);

  /*
   * The size of this grid is 256*32 = 8192.
   */

  size_t threads_per_block = 256;
  size_t number_of_blocks = 32;

  doubleElements<<<number_of_blocks, threads_per_block>>>(a, N);
    err = cudaGetLastError(); 
    if (err != cudaSuccess)
    {
          printf("Error: %s\n", cudaGetErrorString(err));
    }

  checkCuda( cudaDeviceSynchronize() );

  bool areDoubled = checkElementsAreDoubled(a, N);
  printf("All elements were doubled? %s\n", areDoubled ? "TRUE" : "FALSE");

  cudaFree(a);
}
