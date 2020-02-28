;TEST CASES

;For my progeny :')

(list 'Test '1 (if (equal? (expr-compare 12 12) 12) 'Passed 'FAILED))

(list 'Test '2 (if (equal? (expr-compare 12 20) '(if % 12 20)) 'Passed 'FAILED))

(list 'Test '3 (if (equal? (expr-compare #t #t) #t) 'Passed 'FAILED))

(list 'Test '4 (if (equal? (expr-compare #f #f) #f) 'Passed 'FAILED))

(list 'Test '5 (if (equal? (expr-compare #t #f) '%) 'Passed 'FAILED))

(list 'Test '6 (if (equal? (expr-compare #f #t) '(not %)) 'Passed 'FAILED))

(list 'Test '7 (if (equal? (expr-compare 'a '(cons a b)) '(if % a (cons a b))) 'Passed 'FAILED))

(list 'Test '8 (if (equal? (expr-compare'(cons a b) '(cons a b)) '(cons a b)) 'Passed 'FAILED))

(list 'Test '9 (if (equal? (expr-compare '(cons a lambda) '(cons a λ)) '(cons a (if % lambda λ))) 'Passed 'FAILED))

(list 'Test '10 (if (equal? (expr-compare
                            '(cons (cons a b) (cons b c))
                            '(cons (cons a c) (cons a c)))
                           '(cons (cons a (if % b c)) (cons (if % b a) c)))
                   'Passed 'FAILED))

(list 'Test '11 (if (equal? (expr-compare'(cons a b) '(list a b)) '((if % cons list) a b)) 'Passed 'FAILED))

(list 'Test '12 (if (equal? (expr-compare '(list) '(list a)) '(if % (list) (list a))) 'Passed 'FAILED))

(list 'Test '13 (if (equal? (expr-compare ''(a b) ''(a c)) '(if % '(a b) '(a c))) 'Passed 'FAILED))

(list 'Test '14 (if (equal? (expr-compare '(quote (a b)) '(quote (a c))) '(if % '(a b) '(a c))) 'Passed 'FAILED))

(list 'Test '15 (if (equal? (expr-compare'(quoth (a b)) '(quoth (a c))) '(quoth (a (if % b c)))) 'Passed 'FAILED))

(list 'Test '16 (if (equal? (expr-compare '(if x y z) '(if x z z)) '(if x (if % y z) z)) 'Passed 'FAILED))

(list 'Test '17 (if (equal? (expr-compare '(if x y z) '(g x y z)) '(if % (if x y z) (g x y z))) 'Passed 'FAILED))

(list 'Test '18 (if (equal? (expr-compare '((lambda (a) (f a)) 1) '((lambda (a) (g a)) 2)) '((lambda (a) ((if % f g) a)) (if % 1 2))) 'Passed 'FAILED))

(list 'Test '19 (if (equal? (expr-compare '((lambda (a) (f a)) 1) '((λ (a) (g a)) 2)) '((λ (a) ((if % f g) a)) (if % 1 2))) 'Passed 'FAILED))

(list 'Test '20 (if (equal? (expr-compare '((lambda (a) a) c) '((lambda (b) b) d)) '((lambda (a!b) a!b) (if % c d))) 'Passed 'FAILED))

(list 'Test '21 (if (equal? (expr-compare''((λ (a) a) c) ''((lambda (b) b) d)) '(if % '((λ (a) a) c) '((lambda (b) b) d))) 'Passed 'FAILED))

(list 'Test '22 (if (equal? (expr-compare'(+ #f ((λ (a b) (f a b)) 1 2))
              '(+ #t ((lambda (a c) (f a c)) 1 2)))
                            '(+
                              (not %)
                              ((λ (a b!c) (f a b!c)) 1 2))) 'Passed 'FAILED))

(list 'Test '23 (if (equal? (expr-compare '((λ (a b) (f a b)) 1 2)
                                          '((λ (a b) (f b a)) 1 2))
                            '((λ (a b) (f (if % a b) (if % b a))) 1 2)) 'Passed 'FAILED))

(list 'Test '24 (if (equal? (expr-compare'((λ (a b) (f a b)) 1 2)
                                         '((λ (a c) (f c a)) 1 2))
                            '((λ (a b!c) (f (if % a b!c) (if % b!c a))) 1 2)) 'Passed 'FAILED))

(list 'Test '25 (if (equal? (expr-compare '((lambda (lambda) (+ lambda if (f lambda))) 3)
                               '((lambda (if) (+ if if (f λ))) 3))
                           '((lambda (lambda!if) (+ lambda!if (if % if lambda!if) (f (if % lambda!if λ)))) 3)) 'Passed 'FAILED))

(list 'Test '26 (if (equal? (expr-compare '((lambda (a) (eq? a ((λ (a b) ((λ (a b) (a b)) b a))
                                                                a (lambda (a) a))))
                                            (lambda (b a) (b a)))
                                          '((λ (a) (eqv? a ((lambda (b a) ((lambda (a b) (a b)) b a))
                                                            a (λ (b) a))))
                                            (lambda (a b) (a b))))
                            '((λ (a)
                                ((if % eq? eqv?)
                                 a
                                 ((λ (a!b b!a) ((λ (a b) (a b)) (if % b!a a!b) (if % a!b b!a)))
                                  a (λ (a!b) (if % a!b a)))))
                              (lambda (b!a a!b) (b!a a!b)))) 'Passed 'FAILED))

(list 'Test '27 (if (equal? (expr-compare '(cons a lambda) '(cons a λ)) '(cons a (if % lambda λ))) 'Passed 'FAILED))

(list 'Test '28 (if (equal? (expr-compare '(lambda (a) a) '(lambda (b) b)) '(lambda (a!b) a!b)) 'Passed 'FAILED))

(list 'Test '29 (if (equal? (expr-compare '(lambda (a) b) '(cons (c) b)) '(if % (lambda (a) b) (cons (c) b))) 'Passed 'FAILED))

(list 'Test '30 (if (equal? (expr-compare '((λ (if) (+ if 1)) 3) '((lambda (fi) (+ fi 1)) 3)) '((λ (if!fi) (+ if!fi 1)) 3)) 'Passed 'FAILED))

(list 'Test '31 (if (equal? (expr-compare '(lambda (lambda) lambda) '(λ (λ) λ)) '(λ (lambda!λ) lambda!λ)) 'Passed 'FAILED))

(list 'Test '32 (if (equal? (expr-compare ''lambda '(quote λ)) '(if % 'lambda 'λ)) 'Passed 'FAILED))

(list 'Test '33 (if (equal? (expr-compare '(lambda (a b) a) '(λ (b) b)) '(if % (lambda (a b) a) (λ (b) b))) 'Passed 'FAILED))

(list 'Test '34 (if (equal? (expr-compare '(λ (a b) (lambda (b) b)) '(lambda (b) (λ (b) b))) '(if % (λ (a b) (lambda (b) b)) (lambda (b) (λ (b) b)))) 'Passed 'FAILED))

(list 'Test '35 (if (equal? (expr-compare '(λ (let) (let ((x 1)) x)) '(lambda (let) (let ((y 1)) y))) '(λ (let) (let (((if % x y) 1)) (if % x y)))) 'Passed 'FAILED))

(list 'Test '36 (if (equal? (expr-compare '(λ (x) ((λ (x) x) x))
              '(λ (y) ((λ (x) y) x))) '(λ (x!y) ((λ (x) (if % x x!y)) (if % x!y x)))) 'Passed 'FAILED))

(list 'Test '37 (if (equal? (expr-compare '(((λ (g)
                   ((λ (x) (g (λ () (x x))))     ; This is the way we define a recursive function
                    (λ (x) (g (λ () (x x))))))   ; when we don't have 'letrec'
                 (λ (r)                               ; Here (r) will be the function itself
                   (λ (n) (if (= n 0)
                              1
                              (* n ((r) (- n 1))))))) ; Therefore this thing calculates factorial of n
                10)
              '(((λ (x)
                   ((λ (n) (x (λ () (n n))))
                    (λ (r) (x (λ () (r r))))))
                 (λ (g)
                   (λ (x) (if (= x 0)
                              1
                              (* x ((g) (- x 1)))))))
                9)) '(((λ (g!x)
                    ((λ (x!n) (g!x (λ () (x!n x!n))))
                     (λ (x!r) (g!x (λ () (x!r x!r))))))
                  (λ (r!g)
                    (λ (n!x) (if (= n!x 0)
                                 1
                                 (* n!x ((r!g) (- n!x 1)))))))
                 (if % 10 9))) 'Passed 'FAILED))


(list 'EC 'Test '38 (if (equal? (expr-compare '(λ a a) '(λ b b)) '(λ a!b a!b)) 'Passed 'FAILED))

(list 'EC 'Test '39 (if (equal? (expr-compare '(λ a a) '(λ (a) a)) '(if % (λ a a) (λ (a) a))) 'Passed 'FAILED))