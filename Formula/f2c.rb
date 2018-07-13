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

class F2c < Formula
  desc "Fortran 77 to C or C++ converter"
  homepage "http://www.netlib.org/f2c/"
  url "https://drake-homebrew.csail.mit.edu/mirror/f2c-20160102.tar.gz"
  sha256 "feaa7b0549a6d296004b60ec24b2a39e57e2e3dcdef95844205644dc0080c05e"

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/f2c-20160102.patch"
    sha256 "7af4a6f92995c77d62fbe23c46f412fc2358f005fee1885cd37013dfdd742970"
  end

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
  end

  resource "libf2c" do
    url "https://drake-homebrew.csail.mit.edu/mirror/libf2c-20130926.tar.gz"
    sha256 "5dd5a908547794e09cc38966c56f0fb07fedec70ecfb1c28f81a29fa792af85b"

    patch do
      url "https://drake-homebrew.csail.mit.edu/patches/libf2c-20130926.patch"
      sha256 "3039635f0ef4c9e137ea4616c9ffb4b9df0ed9479e769ca2d9948a0f5ae0855e"
    end
  end

  def install
    resources.each { |r| r.stage(buildpath/r.name) }

    cd "libf2c" do
      system "make", "-f", "makefile.u", "CFLAGS=-fPIC"
      system "#{ENV.cc} -dynamiclib -install_name @rpath/libf2c.2.dylib -undefined dynamic_lookup -o libf2c.2.1.dylib *.o"
      ln_s "libf2c.2.1.dylib", "libf2c.2.dylib"
      ln_s "libf2c.2.dylib", "libf2c.dylib"
      include.install "f2c.h"
      lib.install "libf2c.a", "libf2c.dylib", "libf2c.2.dylib", "libf2c.2.1.dylib"
    end

    cd "src" do
      system "make", "-f", "makefile.u", "f2c"
      bin.install "f2c"
    end

    bin.install "fc"
    doc.install "f2c.ps"
    man1.install "fc.1", "f2c.1"
  end

  test do
    (testpath/"test.f").write <<-EOS
      PROGRAM MAIN
        IMPLICIT NONE
        PRINT '(A)', 'Hello, world!'
        STOP
      END
    EOS
    system "#{bin}/f2c", "test.f"
    assert_predicate testpath/"test.c", :exist?
    system ENV.cc, "test.c", "-lf2c"
    assert_match "Hello, world!", shell_output("#{testpath}/a.out")
  end
end
