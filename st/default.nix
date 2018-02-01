self: super: let
    openUrlCmd = super.writeScript "openUrlCmd" ''
      ${super.xurls}/bin/xurls | ${super.rofi}/bin/rofi -dmenu | xargs -r ${super.firefox}/bin/firefox
    '';
  in {
  st = super.st.overrideDerivation (old: {
    patches = old.patches ++ [
          # scrollback patches from https://st.suckless.org/patches/scrollback/
          # https://st.suckless.org/patches/scrollback/st-scrollback-0.7.diff
          ./st-scrollback-0.7.diff
          ./st-no_bold_colors-0.7.diff
          ./st-externalpipe-0.7.diff
          #./st-scrollback-20170329-149c0d3.diff
          # https://st.suckless.org/patches/scrollback/st-scrollback-mouse-20170427-5a10aca.diff
          #./st-scrollback-mouse-20170427-5a10aca.diff
    ];
    enableParallelBuilds = true;
    prePatch = ''
      cp ${(super.substituteAll { src = ./config.h; inherit openUrlCmd; })} config.h
    '';
  });
}
