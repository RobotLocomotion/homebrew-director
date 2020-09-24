# Copyright (c) 2020, Massachusetts Institute of Technology.
# Copyright (c) 2020, Toyota Research Institute.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

cask "drake" do
  version "0.23.0"
  sha256 "9b1c65f0eb7f1952b4207b31e207d1ae26c1f8f068922d99ea7fa33f9e30ca25"

  # github.com/RobotLocomotion/drake was verified as official when first introduced to the cask
  url "https://github.com/RobotLocomotion/drake/releases/download/v#{version}/drake-20200913-mac.tar.gz"
  appcast "https://github.com/RobotLocomotion/drake/releases.atom"
  name "Drake"
  desc "Model-based design and verification for robotics"
  homepage "https://drake.mit.edu/"

  depends_on cask: "adoptopenjdk"
  depends_on formula: "eigen"
  depends_on formula: "gcc"
  depends_on formula: "gflags"
  depends_on formula: "glew"
  depends_on formula: "glib"
  depends_on formula: "graphviz"
  depends_on formula: "dreal-deps/ibex/ibex@2.7.4"
  depends_on formula: "ipopt"
  depends_on formula: "libyaml"
  depends_on formula: "lz4"
  depends_on formula: "nlopt"
  depends_on formula: "numpy"
  depends_on formula: "openblas"
  depends_on formula: "python@3.8"
  depends_on formula: "scipy"
  depends_on formula: "suite-sparse"
  depends_on formula: "tinyxml"
  depends_on formula: "tinyxml2"
  depends_on formula: "robotlocomotion/director/vtk@8.2"
  depends_on formula: "yaml-cpp"
  depends_on formula: "zeromq"
  depends_on macos: ">= :mojave"

  artifact "drake", target: "/opt/drake"

  postflight do
    system_command "/usr/local/bin/pip3",
                   args: [
                     "install",
                     "--disable-pip-version-check",
                     "--ignore-installed",
                     "--isolated",
                     "--no-cache-dir",
                     "--no-compile",
                     "--no-warn-script-location",
                     "--prefix",
                     "/opt/drake",
                     "lxml",
                     "matplotlib",
                     "pydot",
                     "PyYAML",
                     "pyzmq",
                     "tornado",
                     "u-msgpack-python",
                   ]

    FileUtils.rm_rf Dir[
      "/opt/drake/bin/f2py*",
      "/opt/drake/lib/python3.8/site-packages/numpy",
      "/opt/drake/lib/python3.8/site-packages/*.dist-info",
    ]
  end

  uninstall delete: ["/opt/drake"]

  caveats do
    path_environment_variable "/opt/drake/bin"

    <<~EOS
      For compilers to find #{token} you may need to set:
        export LDFLAGS="-L/opt/drake/lib -Wl,-rpath,/opt/drake/lib"
        export CPPFLAGS="-I/opt/drake/include"

      For python3 to find #{token} you may need to set:
        export PYTHONPATH="/opt/drake/lib/python3.8/site-packages:$PYTHONPATH"

      The SNOPT sparse nonlinear optimizer is incorporated into #{token} by kind
      permission of its author Philip E. Gill.
    EOS
  end
end
