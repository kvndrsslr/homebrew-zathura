class Zathura < Formula
  desc "PDF viewer"
  homepage "https://pwmt.org/projects/zathura/"
  url "https://github.com/pwmt/zathura/archive/0.4.9.tar.gz"
  sha256 "82235cbc89899421fca98477265626f2149df7d072740f0360550cc8d4e449d6"
  revision 0
  head "https://github.com/pwmt/zathura.git", branch: "develop"

  depends_on "cmake" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "adwaita-icon-theme"
  depends_on "desktop-file-utils"
  depends_on "gettext"
  depends_on "girara"
  depends_on "glib"
  depends_on "intltool"
  depends_on "libmagic"
  depends_on "sphinx-doc"
  depends_on "synctex" => :optional
  on_macos do
    depends_on "gtk-mac-integration"
  end

  def install
    # Set Homebrew prefix
    ENV["PREFIX"] = prefix
    # Add the pkgconfig for girara to the PKG_CONFIG_PATH
    # TODO: Find out why it is not added correctly for Linux
    ENV["PKG_CONFIG_PATH"] = "#{ENV["PKG_CONFIG_PATH"]}:#{Formula["girara"].prefix}/lib/x86_64-linux-gnu/pkgconfig"

    inreplace "meson.build" do |s|
      s.gsub! "subdir('doc')", ""
    end

    # Adding in the titlebar modifications

    inreplace "zathura/zathura.c" do |s|
      s.gsub! "GdkWindow* window = gtk_widget_get_window(zathura->ui.session->gtk.view);", "
  GdkWindow* window = gtk_widget_get_window(zathura->ui.session->gtk.view);
  GtkWidget* topLevelWidget = gtk_widget_get_toplevel(zathura->ui.session->gtk.view); // TopLevel is (in zathura) always a GtkWindow, so we just check to see if it is NULL to prevent crashing.
  if (topLevelWidget == NULL) {
    return;
  }
  gtk_window_set_titlebar(GTK_WINDOW(topLevelWidget), gtk_header_bar_new()); // Casting GtkWindow to the GtkWidget to fit the function and creating a new (empty) titlebar."
    end

    inreplace "data/zathura.css_t" do |s|
      s.gsub! "\#@session@ .indexmode:selected {", "
window {
  border-radius: 10px;
}
\#@session@ .statusbar {
  border-radius: 0px 0px 10px 10px; /* Rounding only the bottom corners to correlate with the window. */
}
\#@session@ .indexmode:selected {"
    end

    mkdir "build" do
      system "meson", *std_meson_args, ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    system "true" # TODO
  end
end
