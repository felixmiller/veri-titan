(set-logic ALL)
(declare-fun n () Int)
(declare-fun c () Int)
(declare-fun b () Int)
(declare-fun a () Int)
(assert (let ((a!1 (=> (and (distinct n 0) (= (mod a n) (mod b n)))
               (= (mod (* a c) n) (mod (* b c) n)))))
  (not a!1)))
(check-sat)