document.addEventListener("DOMContentLoaded", function () {
  var header = document.querySelector(".md-header__inner");
  if (!header) return;

  var searchBtn = header.querySelector(".md-search");

  var container = document.createElement("div");
  container.className = "md-header__downloads";

  var pdfLink = document.createElement("a");
  pdfLink.href = "Nobl9_SLO_Best_Practices_Guide.pdf";
  pdfLink.textContent = "PDF";
  pdfLink.title = "Download as PDF";
  pdfLink.setAttribute("download", "");

  var mdLink = document.createElement("a");
  mdLink.href = "Nobl9_SLO_Best_Practices_Guide.md";
  mdLink.textContent = "Markdown";
  mdLink.title = "Download as Markdown";
  mdLink.setAttribute("download", "");

  container.appendChild(pdfLink);
  container.appendChild(mdLink);

  if (searchBtn) {
    header.insertBefore(container, searchBtn);
  } else {
    header.appendChild(container);
  }
});
