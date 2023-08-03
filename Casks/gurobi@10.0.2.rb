# Copyright (c) 2023, Massachusetts Institute of Technology.
# Copyright (c) 2023, Toyota Research Institute.
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

cask "gurobi@10.0.2" do
  version "10.0.2"

  name "Gurobi Optimizer"
  desc "Mathematical programming solver for LP, QP, and MIP problems"
  homepage "https://www.gurobi.com/products/gurobi-optimizer/"

  pkg "gurobi#{version}_macos_universal2.pkg"
  url "https://packages.gurobi.com/#{version.major_minor}/gurobi#{version}_macos_universal2.pkg"
  sha256 "955bb1cfa9a72b09c23af6413a10e95f8e05a189539619495f123ff0f3c258c8"

  # NOTE: conflict with all possible versions of this cask from drake (see note
  # below about uninstall files).
  conflicts_with cask: [
    "gurobi",
    "gurobi80",
    "gurobi@9.5.2",
    # "gurobi@10.0.2",  # This cask.
  ]

  uninstall pkgutil: "com.gurobi.gurobiOptimizer#{version.no_dots}.gurobimac.pkg",
            delete:  [
              "/Library/gurobi#{version.no_dots}",
              "/Library/Java/Extensions/libGurobiJni#{version.major_minor.no_dots}.jnilib",
              # NOTE: these are symlinks and may point to a different gurobi,
              # make sure you `conflicts_with` correctly above.
              "/Library/Java/Extensions/gurobi.jar",
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
