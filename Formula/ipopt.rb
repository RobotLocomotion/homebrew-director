# Copyright 2012-2018 Robot Locomotion Group @ CSAIL. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Copyright 2009-2018 Homebrew contributors.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Ipopt < Formula
  desc "Interior point optimizer"
  homepage "https://projects.coin-or.org/Ipopt/"
  url "https://drake-homebrew.csail.mit.edu/mirror/ipopt-3.12.9.tar.gz"
  sha256 "abd440a8c92df156a62dcb81b2885cdd6acd49a93336c0fd5c9401e0dc64df1a"
  head "https://projects.coin-or.org/svn/Ipopt/trunk", :using => :svn

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "d7e95cf26bd4c5a5d6e15d5acde4a9c540831a9033caa14b2edffc14ac6a7ee4" => :high_sierra
    sha256 "a74b6c03ef7459e77092456d4048baedb4e83ab0767b5d76dc456f1d0a755f15" => :sierra
    sha256 "13af4339c0d3ae56048906e5c2e5c35e4d7122ef716efbab17fa20cc1eb657c1" => :el_capitan
  end

  depends_on "gcc"
  depends_on "mumps@5.1"
  depends_on "pkg-config" => :build

  def install
    ENV.delete("MPICC")
    ENV.delete("MPICXX")
    ENV.delete("MPIFC")
    ENV.fortran

    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--enable-shared",
            "--prefix=#{prefix}",
            "--with-mumps-incdir=#{Formula["mumps@5.1"].include}",
            "--with-mumps-lib=-L#{Formula["mumps@5.1"].lib} -ldmumps -lmpiseq -lmumps_common -lpord"]

    system "./configure", *args
    system "make"

    ENV.deparallelize
    system "make", "install"

    inreplace "#{lib}/pkgconfig/ipopt.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/ipopt.pc", "-framework Accelerate -framework Accelerate", "-framework Accelerate"
  end

  test do
    (testpath/"Version.cpp").write <<~EOS
      #include <cassert>
      #include <IpoptConfig.h>
      int main() {
        assert(IPOPT_VERSION_MAJOR == 3);
        assert(IPOPT_VERSION_MINOR == 12);
        assert(IPOPT_VERSION_RELEASE == 9);
        return 0;
      }
    EOS

    system ENV.cxx, "Version.cpp", "-I#{opt_include}/coin"
    system "./a.out"
  end
end
