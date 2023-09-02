{ stdenv
, lib
, meson
, ninja
, pkg-config
, makeWrapper
, gnome
}:

stdenv.mkDerivation rec {
  pname = "{{ cookiecutter.workflow_name }}-custom-desktop-session";
  version = "2023-08-21";

  src = ./.;
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    makeWrapper
  ];

  passthru.providedSessions = [ "{{ cookiecutter.workflow_name }}" ];

  postInstall = ''
    wrapProgram "$out/libexec/{{ cookiecutter.workflow_name }}-session" \
      --prefix PATH : "${lib.makeBinPath [ gnome.gnome-session ]}"
  '';

  meta = with lib; {
    description = "{{cookiecutter.workflow_description}}";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
