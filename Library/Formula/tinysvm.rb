class Tinysvm < Formula
  desc "Support vector machine library for pattern recognition"
  homepage "http://chasen.org/~taku/software/TinySVM/"
  url "http://chasen.org/~taku/software/TinySVM/src/TinySVM-0.09.tar.gz"
  sha1 "9c3c36454c475180ef6646d059376f35549cad08"

  bottle do
    cellar :any
    sha1 "3d4091d59c33a861cade86fc324f0dfc337c818c" => :yosemite
    sha1 "4a779733c331e5b32d4ba79a51c4ec288ca29314" => :mavericks
    sha1 "ae5f0cd4fdb3b6c6e951791496ba0a0487fb687c" => :mountain_lion
  end

  # Use correct compilation flag
  patch :p0 do
    url "https://trac.macports.org/export/94156/trunk/dports/math/TinySVM/files/patch-configure.diff"
    sha1 "9f59314fa743e98d8fe3e887b58a85f25e4df571"
  end

  def install
    # Needed to select proper getopt, per MacPorts
    ENV.append_to_cflags "-D__GNU_LIBRARY__"

    inreplace "configure", "-O9", "" # clang barfs on -O9

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--disable-shared"
    system "make", "install"
  end

  test do
    (testpath/"train.svmdata").write <<-EOS.undent
    +1 201:1.2 3148:1.8 3983:1 4882:1
    -1 874:0.3 3652:1.1 3963:1 6179:1
    +1 1168:1.2 3318:1.2 3938:1.8 4481:1
    +1 350:1 3082:1.5 3965:1 6122:0.2
    -1 99:1 3057:1 3957:1 5838:0.3
    EOS

    (testpath/"train.svrdata").write <<-EOS.undent
    0.23 201:1.2 3148:1.8 3983:1 4882:1
    0.33 874:0.3 3652:1.1 3963:1 6179:1
    -0.12 1168:1.2 3318:1.2 3938:1.8 4481:1
    EOS

    system "#{bin}/svm_learn", "-t", "1", "-d", "2", "-c", "train.svmdata", "test"
    system "#{bin}/svm_classify", "-V", "train.svmdata", "test"
    system "#{bin}/svm_model", "test"

    assert File.exist? "test"
  end
end
