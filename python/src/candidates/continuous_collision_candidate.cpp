#include "../common.hpp"

#include <ipc/candidates/continuous_collision_candidate.hpp>

namespace py = pybind11;
using namespace ipc;

void define_continuous_collision_candidate(py::module_& m)
{
    py::class_<ContinuousCollisionCandidate>(m, "ContinuousCollisionCandidate")
        .def(
            "ccd",
            [](ContinuousCollisionCandidate& self, const Eigen::MatrixXd& V0,
               const Eigen::MatrixXd& V1, const Eigen::MatrixXi& E,
               const Eigen::MatrixXi& F, const double tmax = 1.0,
               const double tolerance = DEFAULT_CCD_TOLERANCE,
               const long max_iterations = DEFAULT_CCD_MAX_ITERATIONS,
               const double conservative_rescaling =
                   DEFAULT_CCD_CONSERVATIVE_RESCALING) {
                double toi;
                bool r = self.ccd(
                    V0, V1, E, F, toi, tmax, tolerance, max_iterations,
                    conservative_rescaling);
                return std::make_tuple(r, toi);
            },
            R"ipc_Qu8mg5v7(
            Perform narrow-phase CCD on the candidate.

            Parameters:
                V0: Mesh vertex positions at the start of the time step.
                V1: Mesh vertex positions at the end of the time step.
                E: Mesh edges as rows of indicies into V.
                F: Mesh triangular faces as rows of indicies into V.
                tmax: Maximum time (normalized) to look for collisions. Should be in [0, 1].
                tolerance: CCD tolerance used by Tight-Inclusion CCD.
                max_iterations: Maximum iterations used by Tight-Inclusion CCD.
                conservative_rescaling: Conservative rescaling value used to avoid taking steps exactly to impact.

            Returns:
                Tuple of:
                If the candidate had a collision over the time interval.
                Computed time of impact (normalized).
            )ipc_Qu8mg5v7",
            py::arg("V0"), py::arg("V1"), py::arg("E"), py::arg("F"),
            py::arg("tmax") = 1.0, py::arg("tolerance") = DEFAULT_CCD_TOLERANCE,
            py::arg("max_iterations") = DEFAULT_CCD_MAX_ITERATIONS,
            py::arg("conservative_rescaling") =
                DEFAULT_CCD_CONSERVATIVE_RESCALING)
        .def(
            "print_ccd_query", &ContinuousCollisionCandidate::print_ccd_query,
            "", py::arg("V0"), py::arg("V1"), py::arg("E"), py::arg("F"));
}
