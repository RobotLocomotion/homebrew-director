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
