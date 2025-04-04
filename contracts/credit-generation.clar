;; credit-generation.clar
;; Creates tradable units for pollution reduction

(define-data-var last-credit-id uint u0)

(define-map credits
  { credit-id: uint }
  {
    owner: principal,
    facility-id: uint,
    pollutant-type: (string-utf8 50),
    amount: uint,
    verification-date: uint,
    expiration-date: uint,
    active: bool
  }
)

(define-public (generate-credits
    (facility-id uint)
    (pollutant-type (string-utf8 50))
    (amount uint)
    (verification-date uint)
    (expiration-date uint))
  (let ((new-id (+ (var-get last-credit-id) u1)))
    (begin
      ;; In a real implementation, we would verify the facility exists and
      ;; that the reduction is legitimate through an oracle or verification mechanism
      (var-set last-credit-id new-id)
      (map-set credits
        { credit-id: new-id }
        {
          owner: tx-sender,
          facility-id: facility-id,
          pollutant-type: pollutant-type,
          amount: amount,
          verification-date: verification-date,
          expiration-date: expiration-date,
          active: true
        }
      )
      (ok new-id)
    )
  )
)

(define-public (retire-credits (credit-id uint))
  (let ((credit (unwrap! (map-get? credits { credit-id: credit-id }) (err u1))))
    (asserts! (is-eq tx-sender (get owner credit)) (err u2))
    (map-set credits
      { credit-id: credit-id }
      (merge credit { active: false })
    )
    (ok true)
  )
)

(define-read-only (get-credit (credit-id uint))
  (map-get? credits { credit-id: credit-id })
)

(define-read-only (get-credit-count)
  (var-get last-credit-id)
)
