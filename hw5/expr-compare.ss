#lang racket

(provide (all-defined-out))
(provide expr-compare)

(define (lambda? x)
    (and (list? x) (equal? (length x) 3) (member (car x) '(lambda λ)))
)

(define (if? x)
    (and (list? x) (equal? (length x) 4) (member (car x) '(if)))
)

(define (xor a b)
    (not (boolean=? a b))
)

(define (lambda-head x)
    (car x)
)

(define (lambda-args x)
    (cadr x)
)

(define (lambda-body x)
    (caddr x)
)

(define (pick-lambda-type x y)
    (if (equal? x y) x 'λ)
)

(define (bind-val x y)
  (if (equal? x y) x (string->symbol (string-append (string-append (symbol->string x) "!") (symbol->string y))))
)

(define (bind-args bindings1 bindings2 x y)
  (cond
    [(not (list? x))
        (list (hash-set bindings1 x (bind-val x y)) (hash-set bindings2 y (bind-val x y)))
    ]
    [(equal? (length x) 0)
        (list bindings1 bindings2)
    ]
    [else
     (bind-args (hash-set bindings1 (car x) (bind-val (car x) (car y))) (hash-set bindings2 (car y) (bind-val (car x) (car y))) (cdr x) (cdr y))
    ]
  )
)

(define (replace-bindings bindings x)
  (cond
    [(lambda? x)
        (letrec ((x-args (lambda-args x)) (lambda-bindings (bind-args bindings bindings x-args x-args)) (new-binding (car lambda-bindings)))
            (map (lambda (b) (replace-bindings new-binding b)) x)
        )
    ]
    [(list? x)
        (map (lambda (b) (replace-bindings bindings b)) x)
    ]
    [(hash-has-key? bindings x)
        (hash-ref bindings x)
    ]
    [else 
        x
    ]
  )
)

(define (lambda-compare x y)
    (let ((x-head (lambda-head x)) (x-args (lambda-args x)) (x-body (lambda-body x)) (y-head (lambda-head y)) (y-args (lambda-args y)) (y-body (lambda-body y)))
        (cond 
            [(or
                (and 
                    (and (list? x-args) (list? y-args))
                    (not (equal? (length x-args) (length y-args)))
                )
                (xor (list? x-args) (list? y-args))
             )
                (list 'if '% x y)
            ]
            [else
                (letrec ((bindings (bind-args (hash) (hash) x-args y-args))
                        (x-binding (car bindings))
                        (y-binding (cadr bindings))
                        (x-body2 (replace-bindings x-binding x-body))
                        (y-body2 (replace-bindings y-binding y-body)))
                    (cons (pick-lambda-type x-head y-head) (cons (replace-bindings x-binding x-args) (list (expr-compare x-body2 y-body2))))
                )
            ]
        )
    )
)

(define (expr-compare x y)
    (cond 
        [(equal? x y)
            x
        ]
        [(and (boolean? x) (boolean? y))
            (if x '% '(not %))
        ]
        [(and (lambda? x) (lambda? y))
            (lambda-compare x y)
        ]
        [(or (lambda? x) (lambda? y)) 
            (list 'if '% x y)
        ]
        [(and (or (if? x) (if? y)) (not (equal? (car x) (car y))))
            (list 'if '% x y)
        ]
        [(or
            (not (and (list? x) (list? y)))
            (or (not (equal? (length x) (length y))) (equal? (length x) 0))
            (let ((x-head (car x)) (y-head (car y)))
                (or (equal? x-head 'quote) (equal? y-head 'quote))
            )
         )
            (list 'if '% x y)
        ]
        [else
            (let ((x-head (car x)) (y-head (car y)) (x-tail (cdr x)) (y-tail (cdr y)))
                (cons (expr-compare x-head y-head) (expr-compare x-tail y-tail))
            )
        ]
    )
)

(define (test-expr-compare x y) 
  (and (equal? (eval x)
               (eval `(let ((% #t)) ,(expr-compare x y))))
       (equal? (eval y)
               (eval `(let ((% #f)) ,(expr-compare x y))))))

(define test-expr-x `(cons (if 42 'lambda 'if) (cons 'hello ((λ (a d) (- (+ 1 a) ((λ (g) g) 6))) 2 7))))
(define test-expr-y `(cons (if 69 'p 'q) (cons 11 ((lambda (b d) (/ (+ 2 d) ((λ (f) f) 4))) 3 5))))