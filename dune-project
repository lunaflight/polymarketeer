(lang dune 3.16)

(generate_opam_files true)

(source
 (github lunaflight/polymarketeer))

(authors lunaflight)

(maintainers lunaflight)

(package
 (name polymarketeer)
 (synopsis "Polymarket Simulator in OCaml")
 (depends
  (async
   (= "v0.17.0"))
  (async_ssl (= "v0.17.0-1"))
  (cohttp-async (= "v6.1.0"))
  (core
   (= "v0.17.1"))
  dune
  (ocaml
   (>= 5.1.1))
  (yojson
    (= "v2.2.2"))
  ))
