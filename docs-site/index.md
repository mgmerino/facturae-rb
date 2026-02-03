---
layout: default
title: "Facturae"
---

<section class="hero">
  <div class="container">
    <h1>Facturae 3.2.2, ready for Ruby.</h1>
    <p>
      Generate compliant electronic invoices, validate data models, and
      sign XML with XAdES-BES using a focused Ruby gem.
    </p>
    <div class="cta">
      <a class="button primary" href="{{ site.baseurl }}/api/">View API Docs</a>
      <a class="button secondary" href="{{ site.repo_readme_url }}">Get Started</a>
    </div>
  </div>
</section>

<section class="container">
  <div class="feature-grid">
    <div class="feature">
      <h3>Facturae XML</h3>
      <p>Generate Facturae 3.2.2 compliant invoices with builder patterns.</p>
    </div>
    <div class="feature">
      <h3>Model validation</h3>
      <p>Catch errors early with strict, model-based validation.</p>
    </div>
    <div class="feature">
      <h3>XAdES-BES signing</h3>
      <p>Digitally sign invoices using OpenSSL and structured XML builders.</p>
    </div>
  </div>

  <div class="snippet">
    <pre><code class="ruby">document = Facturae::FacturaeDocument.new(
  file_header: Facturae::FileHeader.new(
    modality: "I",
    invoice_issuer_type: "EM",
    batch: { invoices_count: 1, invoice_currency_code: "EUR" }
  )
)

xml = Facturae::FacturaeBuilder.new(document).to_xml</code></pre>
  </div>
</section>
