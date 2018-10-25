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

class VtkAT81 < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  url "https://drake-homebrew.csail.mit.edu/mirror/vtk-8.1.1.tar.gz"
  sha256 "4df403c072e90d85c8ce3430aab20746f05c59f759a8dac0835bf13916ae5f48"
  revision 5

  patch do
    # Do not link against libpython when possible.
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.1.1-optional-python-link.patch"
    sha256 "7be110841dba7033c12578779b5be2d1d45d957be6f5a7c0f889432e34ad0de9"
  end

  patch do
    # Fix various issues with vtkRenderingOSPRay.
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.1.1_2-rendering-ospray.patch"
    sha256 "00ae8e5acfe620094c43c863cf54133426ffb2ca0b4564ff1029868821ef77af"
  end

  patch do
    # Fix issue with vtkOpenGLRenderWindow.
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.1.1-opengl-render-window.patch"
    sha256 "7b4e471c8e103a789175d937f1ef016d17434eed46dcefde07925ed0239a939d"
  end

  patch do
    # Fix compilation against Python 3.7.
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.1.1-python-3.7.patch"
    sha256 "8625d46b74b429a4aa8425ecbbd2ea2ca670f4fdb364a14de3b2ca338d5545bb"
  end

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "ee27d0588e310f6331f55915ef36c2596ba0146e449c44fc14fe9fe1cc4c2317" => :mojave
    sha256 "35e08435e313d3876ab50667eb5dcc49ee5fb77c36a5e35f25ce7fec35a69285" => :high_sierra
  end

  keg_only :versioned_formula

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "freetype"
  depends_on "glew"
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libogg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "lz4"
  depends_on "netcdf"
  depends_on "ospray"
  depends_on "python"
  depends_on "python@2"
  depends_on "qt"
  depends_on "theora"

  def install
    # vtkPython.cmake will reference python@2.
    for python in ["python", "python@2"] do
      if python == "python"
        python_executable = `which python3`.strip
      else
        python_executable = `which python2`.strip
      end

      python_include_dir = `#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'`.chomp
      python_version = "python" + `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp
      python_prefix = `#{python_executable} -c 'import sys;print(sys.prefix)'`.chomp

      if File.exist? "#{python_prefix}/Python"
        python_library = "#{python_prefix}/Python"
      elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.a"
        python_library = "#{python_prefix}/lib/lib#{python_version}.a"
      elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.dylib"
        python_library = "#{python_prefix}/lib/lib#{python_version}.dylib"
      else
        odie "No libpythonX.Y.{dylib|a} file found!"
      end

      python_module_dir = "#{lib}/#{python_version}/site-packages/"

      args = std_cmake_args + %W[
        -DBUILD_SHARED_LIBS=ON
        -DBUILD_TESTING=OFF
        -DCMAKE_INSTALL_NAME_DIR:STRING=#{opt_lib}
        -DCMAKE_INSTALL_RPATH:STRING=#{opt_lib}
        -DModule_vtkRenderingOSPRay=ON
        -DOSPRAY_INSTALL_DIR=#{Formula["ospray"].opt_prefix}
        -DPYTHON_EXECUTABLE='#{python_executable}'
        -DPYTHON_INCLUDE_DIR='#{python_include_dir}'
        -DPYTHON_LIBRARY='#{python_library}'
        -DVTK_ENABLE_VTKPYTHON=OFF
        -DVTK_Group_Qt=ON
        -DVTK_INSTALL_PYTHON_MODULE_DIR='#{python_module_dir}'
        -DVTK_LEGACY_REMOVE=ON
        -DVTK_QT_VERSION:STRING=5
        -DVTK_REQUIRED_OBJCXX_FLAGS=''
        -DVTK_USE_COCOA=ON
        -DVTK_USE_SYSTEM_EXPAT=ON
        -DVTK_USE_SYSTEM_FREETYPE=ON
        -DVTK_USE_SYSTEM_GLEW=ON
        -DVTK_USE_SYSTEM_HDF5=ON
        -DVTK_USE_SYSTEM_JPEG=ON
        -DVTK_USE_SYSTEM_JSONCPP=ON
        -DVTK_USE_SYSTEM_LIBXML2=ON
        -DVTK_USE_SYSTEM_LZ4=ON
        -DVTK_USE_SYSTEM_NETCDF=ON
        -DVTK_USE_SYSTEM_NETCDFCPP=ON
        -DVTK_USE_SYSTEM_OGGTHEORA=ON
        -DVTK_USE_SYSTEM_PNG=ON
        -DVTK_USE_SYSTEM_TIFF=ON
        -DVTK_USE_SYSTEM_ZLIB=ON
        -DVTK_WRAP_PYTHON=ON
      ]

      mkdir "build-#{python}" do
        system "cmake", *args, ".."
        system "make"
        system "make", "install"
      end

      inreplace "#{lib}/cmake/vtk-8.1/Modules/vtkhdf5.cmake",
        "#{HOMEBREW_CELLAR}/hdf5/#{Formula["hdf5"].installed_version}/include",
        Formula["hdf5"].opt_include.to_s
      inreplace "#{lib}/cmake/vtk-8.1/Modules/vtkPython.cmake", lib, opt_lib
      inreplace "#{lib}/cmake/vtk-8.1/Modules/vtkPython.cmake",
        "#{HOMEBREW_CELLAR}/#{python}/#{Formula[python].installed_version}/Frameworks",
        "#{Formula[python].opt_prefix}/Frameworks"
      inreplace "#{lib}/cmake/vtk-8.1/VTKConfig.cmake", prefix, opt_prefix
    end
  end

  test do
    (testpath/"Version.cpp").write <<~EOS
      #include <vtkVersion.h>
      #include <assert.h>
      int main() {
        assert(vtkVersion::GetVTKMajorVersion()==8);
        assert(vtkVersion::GetVTKMinorVersion()==1);
        return 0;
      }
    EOS

    system ENV.cxx, "-std=c++11", "Version.cpp", "-I#{opt_include}/vtk-8.1"
    system "./a.out"
  end
end
