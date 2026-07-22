# Nixpkgs' `glew` is now built with `-DGLEW_EGL=ON`, which drops the GLX
# bindings (`__glewX*` symbols). rpcs3's GLGSRender::update_swap_interval
# links against those bindings via `glewXSwapIntervalEXT` /
# `glewXGetCurrentDisplay`, so the LTO link step fails with:
#   undefined reference to `__glewXSwapIntervalEXT'
# See upstream RPCS3 issue #16819 (rpcs3 does not build against glew+egl).
# Provide a GLX-linked glew and scope it to rpcs3 only via `.override`.
{ ... }:

final: prev: {
  glewGlx = prev.glew.overrideAttrs (old: {
    pname = "glew-glx";
    cmakeFlags = builtins.filter (f: f != "-DGLEW_EGL=ON") (old.cmakeFlags or [ ]);
  });

  rpcs3 = prev.rpcs3.override { glew = final.glewGlx; };
}
