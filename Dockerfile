FROM docker.io/exherbo/exherbo_ci:latest

RUN sed -i "s/build_options: jobs=[0-9]*/build_options: jobs=$(nproc)/" /etc/paludis/options.conf

# Options globales (équivalent USE flags Gentoo)
RUN echo '*/* X opengl wayland icu harfbuzz gobject-introspection glib' >> /etc/paludis/options.conf && \
    echo '*/* GSTREAMER_PLUGINS: opengl opus vorbis' >> /etc/paludis/options.conf && \
    echo 'x11-dri/freeglut -X wayland' >> /etc/paludis/options.conf

RUN cave sync && \
    cave resolve -x1 repository/rust && \
    cave resolve -x1 repository/gnome && \
    cave resolve -x1 repository/desktop && \
    cave resolve -x1 repository/media && \
    cave resolve -x1 repository/scientific && \
    cave resolve -x1 repository/net && \
    cave resolve -x1 repository/perl && \
    cave resolve -x1 repository/cogitri

RUN cave sync && \
    cave resolve -x \
    dev-lang/llvm \
    sys-devel/lld \
    dev-lang/clang && \
    rm -rf /var/cache/paludis/distfiles/*

RUN cave resolve -x \
    dev-lang/rust && \
    rm -rf /var/cache/paludis/distfiles/*

RUN echo 'app-editors/vim build_options: -recommended_tests' >> /etc/paludis/options.conf && \
    cave resolve -x \
    app-editors/vim && \
    rm -rf /var/cache/paludis/distfiles/*

# Bootstrap pass 1: install cycle members with circular features disabled
RUN echo 'dev-libs/glib -gobject-introspection' >> /etc/paludis/options.conf && \
    echo 'media-libs/freetype -harfbuzz' >> /etc/paludis/options.conf && \
    echo 'x11-libs/harfbuzz -gobject-introspection' >> /etc/paludis/options.conf && \
    cave resolve -x --suggestions ignore --recommendations ignore \
    dev-libs/glib \
    media-libs/freetype && \
    rm -rf /var/cache/paludis/distfiles/*

# Bootstrap pass 2: install harfbuzz and gobject-introspection
RUN cave resolve -x --suggestions ignore --recommendations ignore \
    x11-libs/harfbuzz \
    gnome-desktop/gobject-introspection && \
    rm -rf /var/cache/paludis/distfiles/*

# Bootstrap pass 3: rebuild with full features
RUN sed -i '/glib -gobject-introspection/d' /etc/paludis/options.conf && \
    sed -i '/freetype -harfbuzz/d' /etc/paludis/options.conf && \
    sed -i '/harfbuzz -gobject-introspection/d' /etc/paludis/options.conf && \
    cave resolve -x --suggestions ignore --recommendations ignore \
    dev-libs/glib \
    media-libs/freetype \
    x11-libs/harfbuzz && \
    rm -rf /var/cache/paludis/distfiles/*

# Bootstrap cycle 3: mesa <-> wayland <-> xorg-server
# Pass 4: install mesa without X to break mesa<->xorg-server cycle
RUN echo 'x11-dri/mesa -X' >> /etc/paludis/options.conf && \
    echo 'dev-libs/libglvnd -X' >> /etc/paludis/options.conf && \
    cave resolve -x --suggestions ignore --recommendations ignore \
    sys-libs/wayland \
    sys-libs/wayland-protocols \
    dev-libs/libglvnd \
    x11-dri/mesa \
    x11-libs/libxkbcommon \
    x11-apps/xkeyboard-config && \
    rm -rf /var/cache/paludis/distfiles/*

# Pass 5: rebuild mesa+libglvnd with X, skip tests to break test-dep cycle
RUN sed -i '/mesa -X/d' /etc/paludis/options.conf && \
    sed -i '/libglvnd -X/d' /etc/paludis/options.conf && \
    echo 'dev-libs/libglvnd build_options: -recommended_tests' >> /etc/paludis/options.conf && \
    cave resolve -x --suggestions ignore --recommendations ignore \
    x11-dri/mesa dev-libs/libglvnd \
    x11-server/xorg-server \
    x11-dri/glu \
    dev-libs/libepoxy \
    x11-drivers/xf86-video-dummy && \
    rm -rf /var/cache/paludis/distfiles/*

# Install webkit, gtk-layer-shell, git
RUN cave resolve -x --suggestions ignore --recommendations ignore \
    net-libs/webkit \
    wayland-libs/gtk-layer-shell \
    dev-scm/git && \
    cave generate-metadata && \
    rm -rf /var/cache/paludis/distfiles/*

RUN sed -i 's/build_options: jobs=[0-9]*/build_options: jobs=5/' /etc/paludis/options.conf
