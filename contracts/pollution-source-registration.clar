;; pollution-source-registration.clar
;; Registers pollution sources and tracks their emissions

(define-data-var last-facility-id uint u0)

(define-map facilities
  { facility-id: uint }
  {
    owner: principal,
    name: (string-utf8 100),
    location: (string-utf8 100),
    pollutant-type: (string-utf8 50),
    baseline-emissions: uint,
    active: bool
  }
)

(define-public (register-facility
    (name (string-utf8 100))
    (location (string-utf8 100))
    (pollutant-type (string-utf8 50))
    (baseline-emissions uint))
  (let ((new-id (+ (var-get last-facility-id) u1)))
    (begin
      (var-set last-facility-id new-id)
      (map-set facilities
        { facility-id: new-id }
        {
          owner: tx-sender,
          name: name,
          location: location,
          pollutant-type: pollutant-type,
          baseline-emissions: baseline-emissions,
          active: true
        }
      )
      (ok new-id)
    )
  )
)

(define-public (update-emissions (facility-id uint) (new-baseline uint))
  (let ((facility (unwrap! (map-get? facilities { facility-id: facility-id }) (err u1))))
    (asserts! (is-eq tx-sender (get owner facility)) (err u2))
    (map-set facilities
      { facility-id: facility-id }
      (merge facility { baseline-emissions: new-baseline })
    )
    (ok true)
  )
)

(define-public (deactivate-facility (facility-id uint))
  (let ((facility (unwrap! (map-get? facilities { facility-id: facility-id }) (err u1))))
    (asserts! (is-eq tx-sender (get owner facility)) (err u2))
    (map-set facilities
      { facility-id: facility-id }
      (merge facility { active: false })
    )
    (ok true)
  )
)

(define-read-only (get-facility (facility-id uint))
  (map-get? facilities { facility-id: facility-id })
)

(define-read-only (get-facility-count)
  (var-get last-facility-id)
)
