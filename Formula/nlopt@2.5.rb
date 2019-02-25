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
#
# Copyright (c) 2009-2019, Homebrew contributors.
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

class NloptAT25 < Formula
  desc "Nonlinear optimization library"
  homepage "https://nlopt.readthedocs.io/"
  url "https://drake-homebrew.csail.mit.edu/mirror/nlopt-2.5.0.tar.gz"
  sha256 "583a980d267d28289440a21f7ed141ddd51fa8b9802fa84234532852a4514aa6"

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "656c26032a50fd99d2cc1b5825b9fe79b04caa14e7f30bdffe393b1c0a400772" => :mojave
    sha256 "34a50214d3c40a7f780646ba9c0b8c5532e92baec8424d693019aceb638136fc" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build

  def install
    args = std_cmake_args + %w[
      -DBUILD_SHARED_LIBS=ON
      -DNLOPT_CXX=ON
      -DNLOPT_GUILE=OFF
      -DNLOPT_MATLAB=OFF
      -DNLOPT_OCTAVE=OFF
      -DNLOPT_PYTHON=OFF
      -DNLOPT_SWIG=OFF
    ]

    mkdir "build" do
      system "cmake", *args, ".."
      system "make"
      system "make", "install"
    end

    rm_f "#{include}/nlopt.f"
    rm_rf "#{lib}/matlab"

    %w[0.dylib dylib].each do |suffix|
      lib.install_symlink "#{lib}/libnlopt_cxx.#{suffix}" => "#{lib}/libnlopt.#{suffix}"
    end

    inreplace "#{lib}/pkgconfig/nlopt.pc", prefix, opt_prefix
  end

  test do
    (testpath/"version.c").write <<~EOS
      #include <assert.h>
      #include <nlopt.h>
      int main() {
        int major, minor, bugfix;
        nlopt_version(&major, &minor, &bugfix);
        assert(major == 2);
        assert(minor == 5);
        assert(bugfix == 0);
        return 0;
      }
    EOS
    system ENV.cc, "version.c", "-o", "version_c", "-I#{opt_include}", "-L#{opt_lib}", "-lnlopt"
    system "./version_c"

    (testpath/"version.cpp").write <<~EOS
      #include <cassert>
      #include <nlopt.hpp>
      int main() {
        assert(nlopt::version_major() == 2);
        assert(nlopt::version_minor() == 5);
        assert(nlopt::version_bugfix() == 0);
        return 0;
      }
    EOS
    system ENV.cxx, "version.cpp", "-o", "version_cpp", "-I#{opt_include}", "-L#{opt_lib}", "-lnlopt_cxx"
    system "./version_cpp"
  end
end
