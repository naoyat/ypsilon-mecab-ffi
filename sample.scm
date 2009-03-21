(import (rnrs)
        (core)
        (srfi :28)
        (binding mecab-ffi))

(format #t "mecab version: ~s\n" (mecab-version))

(let ([m (mecab-new2 "")]
      [src "でもガミラスはまだまだ遠いかもしれないよ\x0;"])
  ;; (display (mecab-sparse-tostr m src))
  (format #t "~a => \n" src)
  (let loop ((node (mecab-sparse-tonode m src)))
    (unless (mecab-node-eos? node)
      (format #t "~a ~a pos:~d chartype:~d\n"
              (mecab-node-surface node)
              (mecab-node-feature node)
              ;;(mecab-node-length node)
              (mecab-node-posid node)
              (mecab-node-char-type node))
      (loop (mecab-node-next node))
      ))
  (mecab-destroy m))
