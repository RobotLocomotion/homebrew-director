# Copyright (c) 2018, Massachusetts Institute of Technology.
# Copyright (c) 2018, Toyota Research Institute.
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

class LcmAT14 < Formula
  desc "Lightweight communications and marshalling"
  homepage "https://lcm-proj.github.io/"
  url "https://drake-homebrew.csail.mit.edu/mirror/lcm-1.4.0.tar.gz"
  sha256 "149d7076369d261e6adbb25d713dc9e30aeba415f4fc62bb41e748b2eb229b46"
  head "https://github.com/lcm-proj/lcm.git"

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "856dfced45c420bea9fe4846e98679c5865c28d6e017926b0f43132e013b0bf1" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on :java
  depends_on "cmake" => :build
  depends_on "glib"
  depends_on "python" => :optional
  depends_on "python@2" => :recommended

  def install
    args = std_cmake_args + %w[
      -DLCM_ENABLE_EXAMPLES=OFF
      -DLCM_ENABLE_TESTS=OFF
      -DLCM_INSTALL_M4MACROS=OFF
      -DLCM_INSTALL_PKGCONFIG=OFF
    ]

    if build.with?("python") && build.with?("python@2")
      odie "Building with both python and python@2 is NOT supported."
    elsif build.with?("python") || build.with?("python@2")
      python_executable = `which python2`.strip if build.with? "python@2"
      python_executable = `which python3`.strip if build.with? "python"
      args << "-DLCM_ENABLE_PYTHON=ON"
      args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
    else
      args << "-DLCM_ENABLE_PYTHON=OFF"
    end

    mkdir "build" do
      system "cmake", *args, ".."
      system "make"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/lcm-gen", "--version"
  end
end
