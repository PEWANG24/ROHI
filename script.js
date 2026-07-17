(() => {
  const nav = document.getElementById("site-nav");
  const toggle = document.querySelector(".nav-toggle");
  const year = document.getElementById("year");
  const form = document.getElementById("enquiry-form");
  const formDate = document.getElementById("form-date");
  const formStatus = document.getElementById("form-status");
  const header = document.querySelector(".site-header");

  if (year) year.textContent = String(new Date().getFullYear());

  if (formDate && !formDate.value) {
    const d = new Date();
    formDate.value = [
      d.getFullYear(),
      String(d.getMonth() + 1).padStart(2, "0"),
      String(d.getDate()).padStart(2, "0"),
    ].join("-");
  }

  const setNavOpen = (open) => {
    if (!nav || !toggle) return;
    nav.classList.toggle("is-open", open);
    toggle.setAttribute("aria-expanded", open ? "true" : "false");
    toggle.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    document.body.style.overflow = open ? "hidden" : "";
  };

  if (toggle && nav) {
    toggle.addEventListener("click", () => setNavOpen(!nav.classList.contains("is-open")));
    nav.querySelectorAll("a").forEach((a) => a.addEventListener("click", () => setNavOpen(false)));
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") setNavOpen(false);
    });
  }

  if (header) {
    const onScroll = () => {
      header.style.boxShadow = window.scrollY > 10 ? "0 1px 0 rgba(0,0,0,0.06)" : "none";
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
  }

  const reveals = document.querySelectorAll(".reveal");
  if ("IntersectionObserver" in window) {
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          entry.target.classList.add("is-in");
          io.unobserve(entry.target);
        });
      },
      { threshold: 0.12, rootMargin: "0px 0px -40px 0px" }
    );

    reveals.forEach((el, i) => {
      if (
        el.classList.contains("service-card") ||
        el.classList.contains("step-card") ||
        el.classList.contains("why-card") ||
        el.classList.contains("testimonial-card")
      ) {
        el.style.transitionDelay = `${(i % 6) * 60}ms`;
      }
      io.observe(el);
    });
  } else {
    reveals.forEach((el) => el.classList.add("is-in"));
  }

  // Close other service cards when one opens (mobile-friendly accordion)
  document.querySelectorAll(".service-details").forEach((detail) => {
    detail.addEventListener("toggle", () => {
      if (!detail.open) return;
      document.querySelectorAll(".service-details[open]").forEach((other) => {
        if (other !== detail) other.open = false;
      });
    });
  });

  if (form) {
    form.addEventListener("submit", (event) => {
      event.preventDefault();
      const data = new FormData(form);
      const name = String(data.get("name") || "").trim();
      const phone = String(data.get("phone") || "").trim();
      const message = String(data.get("message") || "").trim();
      const yourRef = String(data.get("yourRef") || "").trim();
      const ourRef = String(data.get("ourRef") || "").trim();
      const date = String(data.get("date") || "").trim();

      if (!name || !phone || !message) {
        if (formStatus) {
          formStatus.textContent = "Please complete name, phone, and project details.";
          formStatus.className = "form-note is-error";
        }
        return;
      }

      const lines = [
        "Hello ROHI Construction & Supplies Co Ltd,",
        "",
        "I would like a quotation.",
        "",
        `Name: ${name}`,
        `Phone: ${phone}`,
      ];
      if (yourRef) lines.push(`Your Ref: ${yourRef}`);
      if (ourRef) lines.push(`Our Ref: ${ourRef}`);
      if (date) lines.push(`Date: ${date}`);
      lines.push("", `Project details: ${message}`);

      if (formStatus) {
        formStatus.textContent = "Opening WhatsApp…";
        formStatus.className = "form-note is-success";
      }

      window.open(
        `https://wa.me/254721574645?text=${encodeURIComponent(lines.join("\n"))}`,
        "_blank",
        "noopener,noreferrer"
      );
    });
  }
})();
