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
#
# Copyright (c) 2009-2018, Homebrew contributors.
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

class NloptAT24 < Formula
  desc "Nonlinear optimization library"
  homepage "https://nlopt.readthedocs.io/"
  url "https://drake-homebrew.csail.mit.edu/mirror/nlopt-2.4.2.tar.gz"
  sha256 "8099633de9d71cbc06cd435da993eb424bbcdbded8f803cdaa9fb8c6e09c8e89"
  revision 1

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
  end

  head do
    url "https://github.com/stevengj/nlopt.git"
    option :cxx11
    depends_on "cmake" => :build
  end

  keg_only :versioned_formula

  def install
    if build.head?
      args = std_cmake_args + %w[
        -DBUILD_SHARED_LIBS=ON
        -DNLOPT_CXX=ON"
        -DNLOPT_MATLAB=OFF"
        -DNLOPT_OCTAVE=OFF"
        -DNLOPT_PYTHON=OFF"
        -DNLOPT_SWIG=OFF"
      ]

      mkdir "build" do
        system "cmake", *args, ".."
        system "make"
        system "make", "install"
      end

      rm_rf "#{lib}/matlab"

      %w[0.dylib dylib].each do |suffix|
        lib.install_symlink "#{lib}/libnlopt_cxx.#{suffix}" => "#{lib}/libnlopt.#{suffix}"
      end
    else
      args = %W[
        --enable-shared
        --prefix=#{prefix}
        --with-cxx
        --without-guile
        --without-octave
        --without-python
      ]

      system "./configure", *args
      system "make"
      system "make", "install"

      %w[a 0.dylib dylib].each do |suffix|
        lib.install_symlink "#{lib}/libnlopt_cxx.#{suffix}" => "#{lib}/libnlopt.#{suffix}"
      end
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
        assert(minor == 4);
        assert(bugfix == 2);
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
        assert(nlopt::version_minor() == 4);
        assert(nlopt::version_bugfix() == 2);
        return 0;
      }
    EOS
    system ENV.cxx, "version.cpp", "-o", "version_cpp", "-I#{opt_include}", "-L#{opt_lib}", "-lnlopt_cxx"
    system "./version_cpp"
  end
end
