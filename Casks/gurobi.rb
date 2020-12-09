# Copyright (c) 2019, Massachusetts Institute of Technology.
# Copyright (c) 2019, Toyota Research Institute.
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

cask "gurobi" do
  version "9.0.2"
  sha256 "1d58586f9a33ac7035f51f6a04707248218f70bddbec78cb83f11c986ac652cd"

  url "https://packages.gurobi.com/#{version.major_minor}/gurobi#{version}_mac64.pkg"
  appcast "https://www.gurobi.com/resource/fixes/"
  name "Gurobi Optimizer"
  desc "Mathematical programming solver for LP, QP, and MIP problems"
  homepage "https://www.gurobi.com/products/gurobi-optimizer/"

  conflicts_with cask: "gurobi80"

  pkg "gurobi#{version}_mac64.pkg"

  uninstall pkgutil: "com.gurobi.gurobiOptimizer#{version.no_dots}.gurobimac.pkg",
            delete:  [
              "/Library/gurobi#{version.no_dots}",
              "/Library/Java/Extensions/gurobi.jar",
              "/Library/Java/Extensions/libGurobiJni#{version.major_minor.no_dots}.jnilib",
              "/usr/local/bin/grb_ts",
              "/usr/local/bin/grbcluster",
              "/usr/local/bin/grbgetkey",
              "/usr/local/bin/grbprobe",
              "/usr/local/bin/grbtune",
              "/usr/local/bin/gurobi_cl",
              "/usr/local/bin/gurobi.sh",
              "/usr/local/lib/gurobi.py",
              "/usr/local/lib/libgurobi#{version.major_minor.no_dots}.dylib",
            ]

  caveats do
    files_in_usr_local
    license "https://www.gurobi.com/pdfs/eula/eula-gurobi.pdf"
  end
end
