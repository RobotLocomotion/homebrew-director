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

class IbexAT274 < Formula
  desc "C++ library for constraint processing over real numbers"
  homepage "https://github.com/ibex-team/ibex-lib"
  url "https://github.com/dreal-deps/ibex-lib/archive/ibex-2.7.4_10.tar.gz"
  version "2.7.4"
  sha256 "629c472a67bab7188e00c4e085d28d8ed568e316de3c6df84a6bd0037f602624"
  revision 10

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 cellar: :any, big_sur: "d837cfd8beeba16a1830c81b1927379bb1e7979f3873c8795ced443f9455bae3"
    sha256 cellar: :any, catalina: "8b2ce0b5c70b426b09039c352df61b3ab73e1676d30cbee4ba0fefaaba40de7d"
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => [:build, :test]
  depends_on "clp"

  def install
    ENV.cxx11

    # Reported 9 Oct 2017 https://github.com/ibex-team/ibex-lib/issues/286
    ENV.deparallelize
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --with-optim
      --with-solver
      --with-affine-extended
      --interval-lib=filib
      --lp-lib=clp
      --clp-path=#{Formula["clp"].opt_prefix}
    ]
    system "./waf", "configure", *args
    system "./waf", "install"

    pkgshare.install %w[examples plugins/solver/benchs]
    (pkgshare/"examples/symb01.txt").write <<~EOS
      function f(x)
        return ((2*x,-x);(-x,3*x));
      end
    EOS
    inreplace "#{share}/pkgconfig/ibex.pc", prefix, opt_prefix
  end

  test do
    ENV.cxx11
    cp_r (pkgshare/"examples").children, testpath

    # so that pkg-config can remain a build-time only dependency
    inreplace %w[makefile slam/makefile] do |s|
      s.gsub!(/CXXFLAGS.*pkg-config --cflags ibex./,
              "CXXFLAGS := -I#{include} -I#{include}/ibex "\
                          "-I#{include}/ibex/3rd "\
                          "`PKG_CONFIG_PATH=#{Formula["clp"].opt_lib}/pkgconfig pkg-config --cflags clp`")
      s.gsub!(/LIBS.*pkg-config --libs  ibex./,
              "LIBS := -L#{lib} -libex "\
              "`PKG_CONFIG_PATH=#{Formula["clp"].opt_lib}/pkgconfig pkg-config --libs clp`")
    end

    (1..8).each do |n|
      system "make", "lab#{n}"
      system "./lab#{n}"
    end

    (1..3).each do |n|
      system "make", "-C", "slam", "slam#{n}"
      system "./slam/slam#{n}"
    end
  end
end
