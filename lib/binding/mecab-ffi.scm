(library (binding mecab-ffi)
         (export mecab-new2
                 mecab-version
                 mecab-strerror
                 mecab-destroy
                 mecab-get-partial mecab-set-partial!
                 ;;mecab-get-theta mecab-set-theta!
                 mecab-get-lattice-level mecab-set-lattice-level!
                 mecab-get-all-morphs mecab-set-all-morphs!
                 mecab-sparse-tostr mecab-sparse-tostr2 ;mecab-sparse-tostr3
                 mecab-sparse-tonode mecab-sparse-tonode2
                 mecab-nbest-sparse-tostr mecab-nbest-sparse-tostr2 ;mecab-nbest-sparse-tostr3
                 mecab-nbest-init mecab-nbest-init2
                 mecab-nbest-next-tostr mecab-nbest-next-tostr2
                 mecab-nbest-next-tonode
                 mecab-format-node
                 mecab-dictionary-info

                 mecab-node-prev mecab-node-next mecab-node-enext mecab-node-bnext
                 mecab-node-surface mecab-node-feature mecab-node-id
                 mecab-node-length mecab-node-rlength
                 mecab-node-rc-attr mecab-node-lc-attr
                 mecab-node-posid mecab-node-char-type
                 mecab-node-stat mecab-node-normal? mecab-node-unknown? mecab-node-bos? mecab-node-eos?
                 mecab-node-best?
                 mecab-node-sentence-length
                 ;; mecab-node-alpha mecab-node-beta mecab-node-prob
                 mecab-node-wcost mecab-node-cost
                 mecab-node-token
                 
;                 string->utf8z
                 )
         (import (rnrs) (core)
                 (rnrs r5rs)
;                 (ypsilon ffi)
				 (ffi)
                 )

(define libmecab (load-shared-object "libmecab.1.dylib"))

;(define-c-typedef mecab-t* void*)
(define-c-typedef mecab-node-t*  void*)
(define-c-typedef mecab-node-t** void*)
(define-c-typedef mecab-path-t*  void*)
(define-c-typedef mecab-token-t* void*)

(define-c-struct-type mecab-node-t
  (mecab-node-t*  prev)
  (mecab-node-t*  next)
  (mecab-node-t*  enext)
  (mecab-node-t*  bnext)
  (mecab-path-t*  rpath)
  (mecab-path-t*  lpath)
  (mecab-node-t** begin-node-list)
  (mecab-node-t** end-node-list)
  (char*          surface)
  (char*          feature)
  (int            id)
  (short          length)
  (short          rlength)
  (short          rc-attr)
  (short          lc-attr)
  (short          posid)
  (char           char-type)
  (char           stat)
  (char           is-best)
  (int            sentence-length)
  (int            alpha) ; float
  (int            beta)  ; float
  (int            prob)  ; float
; (float          alpha) ;; => internal inconsistency
; (float          beta)  ;; => internal inconsistency
; (float          prob)  ;; => internal inconsistency
  (short          wcost)
  (long           cost)
  (mecab-token-t* token))

(define (compose f g) (lambda args (f (apply g args))))

(define sizeof-mecab-node-t 88)
(define (void*->mecab-node-t* void*-ptr)
  (make-bytevector-mapping void*-ptr sizeof-mecab-node-t))
(define (char*->string char*-ptr . args)
  (if (null? args)
	  (car (string-split (char*->string char*-ptr 255) #\x0)) ;;
	  (let ((len (car args)))
		(utf8->string (make-bytevector-mapping char*-ptr len))
		)))

(define mecab-new2
  (c-function libmecab "libmecab" void* mecab_new2 (char*)))
(define mecab-version
  (c-function libmecab "libmecab" char* mecab_version ()))
(define mecab-strerror
  (c-function libmecab "libmecab" char* mecab_strerror (void*)))
(define mecab-destroy
  (c-function libmecab "libmecab" void mecab_destroy (void*)))

;; パラメータ変更系
(define mecab-get-partial
  (c-function libmecab "libmecab" int mecab_get_partial (void*)))
(define mecab-set-partial!
  (c-function libmecab "libmecab" void mecab_set_partial (void* int)))
;(define mecab-get-theta
;  (c-function libmecab "libmecab" float mecab_get_theta (void*)))
;(define mecab-set-theta!
;  (c-function libmecab "libmecab" void mecab_set_theta (void* float)))
(define mecab-get-lattice-level
  (c-function libmecab "libmecab" int mecab_get_lattice_level (void*)))
(define mecab-set-lattice-level!
  (c-function libmecab "libmecab" int mecab_set_lattice_level (void* int)))
(define mecab-get-all-morphs
  (c-function libmecab "libmecab" int mecab_get_all_morphs (void*)))
(define mecab-set-all-morphs!
  (c-function libmecab "libmecab" void mecab_set_all_morphs (void* int)))

(define mecab-sparse-tostr
  (c-function libmecab "libmecab" char* mecab_sparse_tostr (void* char*)))
(define mecab-sparse-tostr2
  (c-function libmecab "libmecab" char* mecab_sparse_tostr (void* char* int)))
;(define mecab-sparse-tostr3
;  (c-function libmecab "libmecab" char* mecab_sparse_tostr (void* char* int char* int)))
(define mecab-sparse-tonode
  (compose void*->mecab-node-t*
		   (c-function libmecab "libmecab" void* mecab_sparse_tonode (void* char*))))
(define mecab-sparse-tonode2
  (compose void*->mecab-node-t*
		   (c-function libmecab "libmecab" void* mecab_sparse_tonode2 (void* char* int))))
;(define (mecab-sparse-tonode m str); mecab_node_t* を返す
;  (void*->mecab-node-t* (mecab-sparse-tonode__ m str)))
;(define (mecab-sparse-tonode2 m str len); mecab_node_t* を返す
;  (void*->mecab-node-t* (mecab-sparse-tonode2__ m str len)))

(define mecab-nbest-sparse-tostr
  (c-function libmecab "libmecab" char* mecab_nbest_sparse_tostr (void* int char*)))
(define mecab-nbest-sparse-tostr2
  (c-function libmecab "libmecab" char* mecab_nbest_sparse_tostr2 (void* int char* int)))
;(define mecab-nbest-sparse-tostr3
;  (c-function libmecab "libmecab" char* mecab_nbest_sparse_tostr3 (void* int char int char* int)))
(define mecab-nbest-init
  (c-function libmecab "libmecab" int mecab_nbest_init (void* char*)))
(define mecab-nbest-init2
  (c-function libmecab "libmecab" int mecab_nbest_init2 (void* char* int)))
(define mecab-nbest-next-tostr
  (c-function libmecab "libmecab" char* mecab_nbest_next_tostr (void*)))
(define mecab-nbest-next-tostr2
  (c-function libmecab "libmecab" char* mecab_nbest_next_tostr2 (void* char* int)))
(define mecab-nbest-next-tonode ; mecab_node_t*
  (c-function libmecab "libmecab" void* mecab_nbest_next_tonode (void*)))
(define mecab-format-node
  (c-function libmecab "libmecab" char* mecab_format_node (void* void*))) ; (mecab node)
(define mecab-dictionary-info ; mecab_dictionary_info_t* を返す
  (c-function libmecab "libmecab" void* mecab_dictionary_info (void*)))

;; APIs not supported:
;;  MECAB_DLL_EXTERN int           mecab_do (int argc, char **argv);
;;  MECAB_DLL_EXTERN mecab_t*      mecab_new(int argc, char **argv);
;;  MECAB_DLL_EXTERN int           mecab_dict_index(int argc, char **argv);
;;  MECAB_DLL_EXTERN int           mecab_dict_gen(int argc, char **argv);
;;  MECAB_DLL_EXTERN int           mecab_cost_train(int argc, char **argv);
;;  MECAB_DLL_EXTERN int           mecab_system_eval(int argc, char **argv);
;;  MECAB_DLL_EXTERN int           mecab_test_gen(int argc, char **argv);


;;
;; mecab_node_t
;;
(define (mecab-node-prev node) (void*->mecab-node-t* (mecab-node-t-prev node)))
(define (mecab-node-next node) (void*->mecab-node-t* (mecab-node-t-next node)))
(define (mecab-node-enext node) (void*->mecab-node-t* (mecab-node-t-enext node)))
(define (mecab-node-bnext node) (void*->mecab-node-t* (mecab-node-t-bnext node)))
(define (mecab-node-surface node)
  (char*->string (mecab-node-t-surface node) (mecab-node-t-length node)))
(define (mecab-node-feature node)
  (let ((feature (char*->string (mecab-node-t-feature node))))
	(map (lambda (s) (if (string=? "*" s) #f s))
		 (string-split feature #\,))))
  
(define (mecab-node-id node) (mecab-node-t-id node))
(define (mecab-node-length node) (mecab-node-t-length node))
(define (mecab-node-rlength node) (mecab-node-t-rlength node))
(define (mecab-node-rc-attr node) (mecab-node-t-rc-attr node))
(define (mecab-node-lc-attr node) (mecab-node-t-lc-attr node))
(define (mecab-node-posid node) (mecab-node-t-posid node))
(define (mecab-node-char-type node) (mecab-node-t-char-type node))
(define (mecab-node-stat node)
  (case (mecab-node-t-stat node)
	[(0) 'mecab-nor-node]
	[(1) 'mecab-unk-node]
	[(2) 'mecab-bos-node]
	[(3) 'mecab-eos-node]))

(define (mecab-node-normal? node) (eq? 'mecab-nor-node (mecab-node-stat node)))
(define (mecab-node-unknown? node) (eq? 'mecab-unk-node (mecab-node-stat node)))
(define (mecab-node-bos? node) (eq? 'mecab-bos-node (mecab-node-stat node)))
(define (mecab-node-eos? node) (eq? 'mecab-eos-node (mecab-node-stat node)))
(define (mecab-node-best? node) (= 1 (mecab-node-t-is-best node)))
(define (mecab-node-sentence-length node) ; available only when BOS
  (mecab-node-t-sentence-length node))
;(define (mecab-node-alpha node-ptr)
;  (pointer-ref node-ptr 16))
;(define (mecab-node-beta node-ptr)
;  (pointer-ref node-ptr 17))
;(define (mecab-node-prob node-ptr)
;  (pointer-ref node-ptr 18))
(define (mecab-node-wcost node) (mecab-node-t-wcost node))
(define (mecab-node-cost node) (mecab-node-t-cost node))
(define (mecab-node-token node) (mecab-node-t-token node))


;; from 逆引きScheme
(define (string-split-by-char str spliter)
  (let loop ((ls (string->list str)) (buf '()) (ret '()))
    (if (pair? ls)
      (if (char=? (car ls) spliter)
        (loop (cdr ls) '() (cons (list->string (reverse buf)) ret))
        (loop (cdr ls) (cons (car ls) buf) ret))
      (reverse (cons (list->string (reverse buf)) ret)))))

(define (string-split-by-string str spliter)
  (if (zero? (string-length spliter))
    (list str)
    (let ((spl (string->list spliter)))
      (let loop ((ls (string->list str)) (sp spl) (tmp '()) (buf '()) (ret '()))
        (if (pair? sp)
          (if (pair? ls)
            (if (char=? (car ls) (car sp))
              (loop (cdr ls) (cdr sp) (cons (car ls) tmp) buf ret)
              (loop (cdr ls) spl '() (cons (car ls) (append tmp buf)) ret))
            (reverse (cons (list->string (reverse (append tmp buf))) ret)))
          (loop ls spl '() '() (cons (list->string (reverse buf)) ret)))))))

(define (string-split str spliter)
  (cond [(char? spliter) (string-split-by-char str spliter)]
        [(string? spliter) (string-split-by-string str spliter)]
        [else #f]))

)
