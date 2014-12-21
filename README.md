live-reload
===========

This is a simple program intended to be used together with any static site generator. It adds a web server with live reload. The goal was to write a universal solution that works without injecting any code into your static site. It is a proof of concept and lacks a lot of features. But if it proves to be needed by community I am going to improve and support it.

Using
-----

Clone, install dependencies, then

    cabal run <path to static site root>

Now open your browser at [http://localhost:8000///__index.html](http://localhost:8000///__index.html) and see your site. As soon as the source files update, browser window will automatically reload.

Filenames with non-latin characters are not supported due to an issue in snap-core.
