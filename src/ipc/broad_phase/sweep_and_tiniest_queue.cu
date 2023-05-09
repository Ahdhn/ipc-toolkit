#include "sweep_and_tiniest_queue.hpp"

#include <ipc/config.hpp>

#include <stq/cpu/io.hpp>
#include <stq/cpu/sweep.hpp>
#ifdef IPC_TOOLKIT_WITH_CUDA
#include <ccdgpu/helper.cuh>
#endif

namespace ipc {

#ifdef IPC_TOOLKIT_WITH_CUDA
void SweepAndTiniestQueueGPU::build(
    const Eigen::MatrixXd& vertices,
    const Eigen::MatrixXi& edges,
    const Eigen::MatrixXi& faces,
    double inflation_radius)
{
    CopyMeshBroadPhase::copy_mesh(edges, faces);
    ccd::gpu::construct_static_collision_candidates(
        vertices, edges, faces, overlaps, boxes, inflation_radius);
}

void SweepAndTiniestQueueGPU::build(
    const Eigen::MatrixXd& vertices_t0,
    const Eigen::MatrixXd& vertices_t1,
    const Eigen::MatrixXi& edges,
    const Eigen::MatrixXi& faces,
    double inflation_radius)
{
    CopyMeshBroadPhase::copy_mesh(edges, faces);
    ccd::gpu::construct_continuous_collision_candidates(
        vertices_t0, vertices_t1, edges, faces, overlaps, boxes,
        inflation_radius);
}

void SweepAndTiniestQueueGPU::clear()
{
    BroadPhase::clear();
    overlaps.clear();
    boxes.clear();
}

// Find the candidate edge-vertex collisisons.
void SweepAndTiniestQueueGPU::detect_edge_vertex_candidates(
    std::vector<EdgeVertexCandidate>& candidates) const
{
    // 2D STQ is not implemented!
    throw std::runtime_error("Not implemented!");
    // using namespace stq::gpu;
    // for (const std::pair<int, int>& overlap : overlaps) {
    //     const Aabb& boxA = boxes[overlap.first];
    //     const Aabb& boxB = boxes[overlap.second];
    //     if (is_edge(boxA) && is_vertex(boxB)
    //         && can_edge_vertex_collide(boxA.ref_id, boxB.ref_id)) { // EV
    //         candidates.emplace_back(boxA.ref_id, boxB.ref_id);
    //     } else if (
    //         is_edge(boxB) && is_vertex(boxA)
    //         && can_edge_vertex_collide(boxB.ref_id, boxA.ref_id)) { // VE
    //         candidates.emplace_back(boxB.ref_id, boxA.ref_id);
    //     }
    // }
}

// Find the candidate edge-edge collisions.
void SweepAndTiniestQueueGPU::detect_edge_edge_candidates(
    std::vector<EdgeEdgeCandidate>& candidates) const
{
    using namespace stq::gpu;
    for (const std::pair<int, int>& overlap : overlaps) {
        const Aabb& boxA = boxes[overlap.first];
        const Aabb& boxB = boxes[overlap.second];
        if (is_edge(boxA) && is_edge(boxB)
            && can_edges_collide(boxA.ref_id, boxB.ref_id)) { // EE
            candidates.emplace_back(boxA.ref_id, boxB.ref_id);
        }
    }
}

// Find the candidate face-vertex collisions.
void SweepAndTiniestQueueGPU::detect_face_vertex_candidates(
    std::vector<FaceVertexCandidate>& candidates) const
{
    using namespace stq::gpu;
    for (const std::pair<int, int>& overlap : overlaps) {
        const Aabb& boxA = boxes[overlap.first];
        const Aabb& boxB = boxes[overlap.second];
        if (is_face(boxA) && is_vertex(boxB)
            && can_face_vertex_collide(boxA.ref_id, boxB.ref_id)) { // FV
            candidates.emplace_back(boxA.ref_id, boxB.ref_id);
        } else if (
            is_face(boxB) && is_vertex(boxA)
            && can_face_vertex_collide(boxB.ref_id, boxA.ref_id)) { // VF
            candidates.emplace_back(boxB.ref_id, boxA.ref_id);
        }
    }
}

// Find the candidate edge-face intersections.
void SweepAndTiniestQueueGPU::detect_edge_face_candidates(
    std::vector<EdgeFaceCandidate>& candidates) const
{
    throw std::runtime_error("Not implemented!");
}
#endif

} // namespace ipc