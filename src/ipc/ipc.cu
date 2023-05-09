#include "ipc.hpp"

#ifdef IPC_TOOLKIT_WITH_CUDA
#include <ccdgpu/helper.cuh>
#endif

double ipc::compute_collision_free_stepsize_gpu(
    const CollisionMesh& mesh,
    const Eigen::MatrixXd& vertices_t0,
    const Eigen::MatrixXd& vertices_t1,
    const double min_distance,
    const double tolerance,
    const long max_iterations)
{
#ifdef IPC_TOOLKIT_WITH_CUDA
    const double step_size = ccd::gpu::compute_toi_strategy(
        vertices_t0, vertices_t1, mesh.edges(), mesh.faces(), max_iterations,
        min_distance, tolerance);
    if (step_size < 1.0) {
        return 0.8 * step_size;
    }
    return 1.0;
#else
    throw std::runtime_error(
        "GPU Sweep and Tiniest Queue is disabled because CUDA is disabled!");
#endif
}