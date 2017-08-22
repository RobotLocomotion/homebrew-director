# Copyright 2012-2017 Robot Locomotion Group @ CSAIL. All rights reserved.
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

# Copyright 2009-2017 Homebrew contributors.
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

class VtkAT71 < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization."
  homepage "http://www.vtk.org/"
  head "https://gitlab.kitware.com/vtk/vtk.git"

  stable do
    url "https://donn8mmazi9jw.cloudfront.net/mirror/vtk-7.1.1.tar.gz"
    sha256 "2d5cdd048540144d821715c718932591418bb48f5b6bb19becdae62339efa75a"

    patch do
      # Do not link against libpython when possible.
      url "https://donn8mmazi9jw.cloudfront.net/patches/vtk-7.1.1-optional-python-link.patch"
      sha256 "735ed5ad66bcad51010a5e922b03fd6ae2064a1074a9a4671f313c3543f9eef6"
    end
  end

  bottle do
    root_url "https://donn8mmazi9jw.cloudfront.net/bottles"
    rebuild 1
    sha256 "929ebc858d35fef61ebeaebfbfff384c6cf00cdb20afa4812fb10a8948d305b9" => :sierra
    sha256 "d2780a7329f8baba3e210b8e580aed3d52af00df0abdb328bcf333d7bea1ce68" => :el_capitan
    sha256 "db0f84274b5d0047d581365d0740d5c717931a30c90c35e40ea6ad8bdc2cd2df" => :yosemite
  end

  keg_only :versioned_formula

  option :cxx11

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on "cmake" => :build
  depends_on "freetype"
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libogg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "netcdf"
  depends_on "qt" => :recommended
  depends_on "theora"

  def install
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_TESTING=OFF
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{opt_lib}
      -DCMAKE_INSTALL_RPATH:STRING=#{opt_lib}
      -DVTK_REQUIRED_OBJCXX_FLAGS=''
      -DVTK_USE_COCOA=ON
      -DVTK_USE_SYSTEM_EXPAT=ON
      -DVTK_USE_SYSTEM_FREETYPE=ON
      -DVTK_USE_SYSTEM_HDF5=ON
      -DVTK_USE_SYSTEM_JPEG=ON
      -DVTK_USE_SYSTEM_JSONCPP=ON
      -DVTK_USE_SYSTEM_LIBXML2=ON
      -DVTK_USE_SYSTEM_NETCDF=ON
      -DVTK_USE_SYSTEM_OGGTHEORA=ON
      -DVTK_USE_SYSTEM_PNG=ON
      -DVTK_USE_SYSTEM_TIFF=ON
      -DVTK_USE_SYSTEM_ZLIB=ON
    ]

    if build.with? "qt"
      args << "-DVTK_QT_VERSION:STRING=5"
      args << "-DVTK_Group_Qt=ON"
    end

    unless MacOS::CLT.installed?
      # We are facing an Xcode-only installation, and we have to keep
      # vtk from using its internal Tk headers (that differ from OSX's).
      args << "-DTK_INCLUDE_PATH:PATH=#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Headers"
      args << "-DTK_INTERNAL_PATH:PATH=#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Headers/tk-private"
    end

    ENV.cxx11 if build.cxx11?

    mkdir "build" do
      if build.with?("python3") && build.with?("python")
        # VTK Does not support building both python 2 and 3 versions
        odie "VTK: Does not support building both python 2 and 3 wrappers"
      elsif build.with?("python") || build.with?("python3")
        python_executable = `which python2`.strip if build.with? "python"
        python_executable = `which python3`.strip if build.with? "python3"

        python_prefix = `#{python_executable} -c 'import sys;print(sys.prefix)'`.chomp
        python_include = `#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'`.chomp
        python_version = "python" + `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp
        py_site_packages = "#{lib}/#{python_version}/site-packages"

        args << "-DVTK_WRAP_PYTHON=ON"
        args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
        args << "-DPYTHON_INCLUDE_DIR='#{python_include}'"
        # CMake picks up the system's python dylib, even if we have a brewed one.
        if File.exist? "#{python_prefix}/Python"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/Python'"
        elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.a"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.a'"
        elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.dylib"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.dylib'"
        else
          odie "No libpythonX.Y.{dylib|a} file found!"
        end
        # Set the prefix for the python bindings to the Cellar
        args << "-DVTK_INSTALL_PYTHON_MODULE_DIR='#{py_site_packages}/'"
      end

      args << ".."
      system "cmake", *args
      system "make"
      system "make", "install"

      inreplace "#{lib}/cmake/vtk-7.1/Modules/vtkhdf5.cmake", "#{HOMEBREW_CELLAR}/hdf5/#{Formula["hdf5"].installed_version}/include", "#{Formula["hdf5"].opt_include}"
      if build.with?("python")
        inreplace "#{lib}/cmake/vtk-7.1/Modules/vtkPython.cmake", "#{HOMEBREW_CELLAR}/python/#{Formula["python"].installed_version}/Frameworks", "#{Formula["python"].opt_prefix}/Frameworks"
      else
        inreplace "#{lib}/cmake/vtk-7.1/Modules/vtkPython.cmake", "#{HOMEBREW_CELLAR}/python3/#{Formula["python3"].installed_version}/Frameworks", "#{Formula["python3"].opt_prefix}/Frameworks"
      end
      inreplace "#{lib}/cmake/vtk-7.1/VTKConfig.cmake", prefix, opt_prefix
    end
  end

  test do
    (testpath/"Version.cpp").write <<-EOS
        #include <vtkVersion.h>
        #include <assert.h>
        int main() {
          assert(vtkVersion::GetVTKMajorVersion()==7);
          assert(vtkVersion::GetVTKMinorVersion()==1);
          return 0;
        }
      EOS

    system ENV.cxx, "Version.cpp", "-I#{opt_include}/vtk-7.1"
    system "./a.out"
    system "#{bin}/vtkpython", "-c", "exit()"
  end
end
