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
#
# Copyright (c) 2009-2020, Homebrew contributors.
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

class ScipyAT154 < Formula
  desc "Software for mathematics, science, and engineering"
  homepage "https://www.scipy.org"
  url "https://files.pythonhosted.org/packages/aa/d5/dd06fe0e274e579e1dff21aa021219c039df40e39709fabe559faed072a5/scipy-1.5.4.tar.gz"
  sha256 "4a453d5e5689de62e5d38edf40af3f17560bfd63c9c5bd228c18c1f99afa155b"
  license "BSD-3-Clause"

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "959f3e8ba539921ff075bcf07a5fca1b8482c6cd57ef32ab6b94489561f84428" => :big_sur
    sha256 "e868bc9b4de29a00bb03d7f81e61a2bb74861149a07db51847b810c36cc17c97" => :catalina
  end

  depends_on "pybind11" => :build
  depends_on "gcc"
  depends_on "numpy@1.19.4"
  depends_on "openblas"
  depends_on "python@3.8"

  cxxstdlib_check :skip

  def install
    openblas = Formula["openblas"].opt_prefix
    ENV["ATLAS"] = "None"
    ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/#{shared_library("libopenblas")}"

    config = <<~EOS
      [DEFAULT]
      library_dirs = #{HOMEBREW_PREFIX}/lib
      include_dirs = #{HOMEBREW_PREFIX}/include
      [openblas]
      libraries = openblas
      library_dirs = #{openblas}/lib
      include_dirs = #{openblas}/include
    EOS

    Pathname("site.cfg").write config

    version = Language::Python.major_minor_version Formula["python@3.8"].opt_bin/"python3"
    ENV["PYTHONPATH"] = Formula["numpy@1.19.4"].opt_lib/"python#{version}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"

    system Formula["python@3.8"].opt_bin/"python3", "setup.py",
      "build", "--fcompiler=gnu95"
    system Formula["python@3.8"].opt_bin/"python3",
      *Language::Python.setup_install_args(prefix)
  end

  def post_install
    rm_f Dir["#{HOMEBREW_PREFIX}/lib/python*.*/site-packages/scipy/**/*.pyc"]
  end

  test do
    system Formula["python@3.8"].opt_bin/"python3", "-c", "import scipy"
  end
end
