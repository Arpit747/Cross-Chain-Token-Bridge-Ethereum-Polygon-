(define-map user-locked-tokens
  {user: principal}     ;; key
  {amount: uint})       ;; value

(define-data-var total-locked uint u0)

(define-constant err-invalid-amount (err u100))
(define-constant err-no-tokens-locked (err u101))

;; Lock tokens for bridging to Ethereum/Polygon
(define-public (lock-tokens (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (let ((current (default-to u0 (get amount (map-get? user-locked-tokens {user: tx-sender})))))
      (map-set user-locked-tokens {user: tx-sender} {amount: (+ current amount)}))
    (var-set total-locked (+ (var-get total-locked) amount))
    (ok true)))

;; View user's locked token amount
(define-read-only (get-locked-by-user)
  (let ((entry (map-get? user-locked-tokens {user: tx-sender})))
    (ok (match entry
         val (some {amount: (get amount val)})
         none))))

;; Get total locked amount in the bridge
(define-read-only (get-total-locked)
  (ok (var-get total-locked)))
