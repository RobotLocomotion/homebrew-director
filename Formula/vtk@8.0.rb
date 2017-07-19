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

class VtkAT80 < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization."
  homepage "http://www.vtk.org/"
  head "https://gitlab.kitware.com/vtk/vtk.git"

  stable do
    url "https://donn8mmazi9jw.cloudfront.net/mirror/vtk-8.0.0.tar.gz"
    sha256 "c7e727706fb689fb6fd764d3b47cac8f4dc03204806ff19a10dfd406c6072a27"

    patch do
      # Do not link against libpython when possible.
      url "https://donn8mmazi9jw.cloudfront.net/patches/vtk-8.0.0-optional-python-link.patch"
      sha256 "dd5d30cd80a9d5cddb6d648ddcea3c8c36d809407084b0ab09848d1981ffb6dc"
    end
  end

  bottle do
    root_url "https://donn8mmazi9jw.cloudfront.net/bottles"
    sha256 "45627a2657a6b4bde6c69e1cdc099dea83d8321dba652e0188d71e408b8b61ea" => :sierra
    sha256 "42c0a2e7bc5f07bd6c32114f8cf1c2873b0cd31026380072935245ddd54f4206" => :el_capitan
    sha256 "15d7dd02c6a2705e5b6198e16262c8ea0017d545201f3aa64ecc834728a7237b" => :yosemite
  end

  keg_only :versioned_formula

  option :cxx11
  option "with-examples", "Compile and install various examples"
  option "with-tcl", "Enable Tcl wrapping of VTK classes"
  option "with-matplotlib", "Enable matplotlib support"
  option "without-legacy", "Disable legacy APIs"
  option "without-python", "Build without python2 support"

  depends_on "cmake" => :build

  unless OS.mac?
    depends_on "libxml2"
    depends_on "linuxbrew/xorg/mesa"
  end

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on "matplotlib" => :python if build.with?("matplotlib") && build.with?("python") # homebrew/science

  depends_on "freetype" => :recommended
  depends_on "glew" => :recommended
  depends_on "hdf5" => :recommended
  depends_on "jpeg" => :recommended
  depends_on "jsoncpp" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "netcdf" => :recommended # homebrew/science
  depends_on "qt" => :recommended
  depends_on "zlib" => :recommended

  depends_on "boost" => :optional
  depends_on "fontconfig" => :optional
  depends_on :x11 => :optional

  # If --with-qt and --with-python or --with-python3, then we automatically use
  # PyQt, too!
  if build.with?("qt") && (build.with?("python") || build.with?("python3"))
    depends_on "pyqt"
    depends_on "sip"
  end

  def install
    dylib = OS.mac? ? "dylib" : "so"

    args = std_cmake_args + %W[
      -DVTK_REQUIRED_OBJCXX_FLAGS=''
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DVTK_USE_SYSTEM_EXPAT=ON
      -DVTK_USE_SYSTEM_LIBXML2=ON
      -DVTK_USE_SYSTEM_ZLIB=ON
    ]

    args << "-DBUILD_EXAMPLES=" + ((build.with? "examples") ? "ON" : "OFF")

    if build.with? "examples"
      args << "-DBUILD_TESTING=ON"
    else
      args << "-DBUILD_TESTING=OFF"
    end

    if build.with? "qt"
      args << "-DVTK_QT_VERSION:STRING=5"
      args << "-DVTK_Group_Qt=ON"
    end

    args << "-DVTK_WRAP_TCL=ON" if build.with? "tcl"

    # Cocoa for everything except x11
    if build.with? "x11"
      args << "-DVTK_USE_COCOA=OFF"
      args << "-DVTK_USE_X=ON"
      args << "-DOPENGL_INCLUDE_DIR:PATH=/usr/X11R6/include"
      args << "-DOPENGL_gl_LIBRARY:STRING=/usr/X11R6/lib/libGL.dylib"
      args << "-DOPENGL_glu_LIBRARY:STRING=/usr/X11R6/lib/libGLU.dylib"
    else
      args << "-DVTK_USE_COCOA=ON"
    end

    unless MacOS::CLT.installed?
      # We are facing an Xcode-only installation, and we have to keep
      # vtk from using its internal Tk headers (that differ from OSX's).
      args << "-DTK_INCLUDE_PATH:PATH=#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Headers"
      args << "-DTK_INTERNAL_PATH:PATH=#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Headers/tk-private"
    end

    args << "-DModule_vtkInfovisBoost=ON" << "-DModule_vtkInfovisBoostGraphAlgorithms=ON" if build.with? "boost"
    args << "-DModule_vtkRenderingFreeTypeFontConfig=ON" if build.with? "fontconfig"
    args << "-DVTK_USE_SYSTEM_FREETYPE=ON" if build.with? "freetype"
    args << "-DVTK_USE_SYSTEM_GLEW=ON" if build.with? "glew"
    args << "-DVTK_USE_SYSTEM_HDF5=ON" if build.with? "hdf5"
    args << "-DVTK_USE_SYSTEM_JPEG=ON" if build.with? "jpeg"
    args << "-DVTK_USE_SYSTEM_JSONCPP=ON" if build.with? "jsoncpp"
    args << "-DVTK_USE_SYSTEM_NETCDF=ON" if build.with? "netcdf"
    args << "-DVTK_USE_SYSTEM_PNG=ON" if build.with? "libpng"
    args << "-DVTK_USE_SYSTEM_TIFF=ON" if build.with? "libtiff"
    args << "-DModule_vtkRenderingMatplotlib=ON" if build.with?("matplotlib") && build.with?("python")
    args << "-DVTK_LEGACY_REMOVE=ON" if build.without? "legacy"

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
        elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.#{dylib}"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.#{dylib}'"
        elsif File.exist? "#{python_prefix}/lib/x86_64-linux-gnu/lib#{python_version}.so"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/x86_64-linux-gnu/lib#{python_version}.so'"
        else
          odie "No libpythonX.Y.{#{dylib}|a} file found!"
        end
        # Set the prefix for the python bindings to the Cellar
        args << "-DVTK_INSTALL_PYTHON_MODULE_DIR='#{py_site_packages}/'"

        if build.with? "qt"
          args << "-DVTK_WRAP_PYTHON_SIP=ON"
          args << "-DSIP_PYQT_DIR='#{Formula["pyqt"].opt_share}/sip'"
        end
      end

      args << ".."
      system "cmake", *args
      system "make"
      system "make", "install"

      if build.with? "hdf5"
        inreplace "#{lib}/cmake/vtk-8.0/Modules/vtkhdf5.cmake", "#{HOMEBREW_CELLAR}/hdf5/#{Formula["hdf5"].installed_version}/include", "#{Formula["hdf5"].opt_include}"
      end
      if build.with?("python") || build.with?("python3")
        inreplace "#{lib}/cmake/vtk-8.0/Modules/vtkPython.cmake", lib, opt_lib
        if build.with?("python")
          inreplace "#{lib}/cmake/vtk-8.0/Modules/vtkPython.cmake", "#{HOMEBREW_CELLAR}/python/#{Formula["python"].installed_version}/Frameworks", "#{Formula["python"].opt_prefix}/Frameworks"
        else
          inreplace "#{lib}/cmake/vtk-8.0/Modules/vtkPython.cmake", "#{HOMEBREW_CELLAR}/python3/#{Formula["python3"].installed_version}/Frameworks", "#{Formula["python3"].opt_prefix}/Frameworks"
        end
      end
      inreplace "#{lib}/cmake/vtk-8.0/VTKConfig.cmake", prefix, opt_prefix
      inreplace "#{lib}/cmake/vtk-8.0/VTKTargets-release.cmake", lib, opt_lib
    end

    pkgshare.install "Examples" if build.with? "examples"
  end

  test do
    (testpath/"Version.cpp").write <<-EOS
        #include <vtkVersion.h>
        #include <assert.h>
        int main() {
          assert(vtkVersion::GetVTKMajorVersion()==8);
          assert(vtkVersion::GetVTKMinorVersion()==0);
          return 0;
        }
      EOS

    system ENV.cxx, "Version.cpp", "-I#{opt_include}/vtk-8.0"
    system "./a.out"
    system "#{bin}/vtkpython", "-c", "exit()"
  end
end
