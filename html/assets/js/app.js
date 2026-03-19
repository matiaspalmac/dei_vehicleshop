(function () {
  var $ = function (s) { return document.querySelector(s); };
  var $$ = function (s) { return document.querySelectorAll(s); };

  var IS_BROWSER = !window.invokeNative;

  var vehicles = [];
  var filteredVehicles = [];
  var selectedModel = null;
  var currentCategory = 'all';
  var currentSort = 'price-asc';
  var categories = [];
  var shopCategories = [];
  var isDealer = false;
  var sellingTo = null;
  var enableTestDrive = true;
  var confirmModel = null;

  var els = {
    overlay: $('#shop-overlay'),
    container: $('#shop-container'),
    shopName: $('#shop-name'),
    searchInput: $('#search-input'),
    sortDropdown: $('#sort-dropdown'),
    closeBtn: $('#close-btn'),
    sidebar: $('#sidebar'),
    mainContent: $('#main-content'),
    vehicleGrid: $('#vehicle-grid'),
    gridCount: $('#grid-count'),
    detailPanel: $('#detail-panel'),
    detailEmpty: $('#detail-empty'),
    detailContent: $('#detail-content'),
    detailName: $('#detail-name'),
    detailCategory: $('#detail-category'),
    detailClass: $('#detail-class'),
    detailSeatsValue: $('#detail-seats-value'),
    detailPrice: $('#detail-price'),
    detailCatValue: $('#detail-cat-value'),
    detailClassValue: $('#detail-class-value'),
    detailPayMethod: $('#detail-pay-method'),
    statSpeed: $('#stat-speed'),
    statSpeedFill: $('#stat-speed-fill'),
    statAccel: $('#stat-accel'),
    statAccelFill: $('#stat-accel-fill'),
    statBrake: $('#stat-brake'),
    statBrakeFill: $('#stat-brake-fill'),
    statHandling: $('#stat-handling'),
    statHandlingFill: $('#stat-handling-fill'),
    btnTestdrive: $('#btn-testdrive'),
    btnBuy: $('#btn-buy'),
    btnBack: $('#btn-back'),
    sellingBadge: $('#selling-badge'),
    confirmModal: $('#confirm-modal'),
    confirmDesc: $('#confirm-desc'),
    confirmPrice: $('#confirm-price'),
    btnConfirmBuy: $('#btn-confirm-buy'),
    btnCancelBuy: $('#btn-cancel-buy'),
    testDriveTimer: $('#test-drive-timer'),
    timerValue: $('#timer-value'),
    timerVehicle: $('#timer-vehicle'),
  };

  // ===== Category Icons =====
  var categoryIcons = {
    all: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>',
    sedan: '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M18.92 6.01C18.72 5.42 18.16 5 17.5 5h-11c-.66 0-1.21.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.5 16c-.83 0-1.5-.67-1.5-1.5S5.67 13 6.5 13s1.5.67 1.5 1.5S7.33 16 6.5 16zm11 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zM5 11l1.5-4.5h11L19 11H5z"/></svg>',
    deportivo: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 17h2l2-4h6l2 4h2"/><circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/><path d="M3 17h2m12 0h4v-4l-3-5H8L5 13v4"/></svg>',
    super: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>',
    suv: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="3" width="15" height="13" rx="2" ry="2"/><path d="M16 8h4l3 4v5h-3"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>',
    compacto: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="10" rx="2"/><circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/></svg>',
    moto: '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19.44 9.03L15.41 5H11v2h3.59l2 2H5c-2.8 0-5 2.2-5 5s2.2 5 5 5c2.46 0 4.45-1.69 4.9-4h1.65l2.77-2.77c-.21.54-.32 1.14-.32 1.77 0 2.8 2.2 5 5 5s5-2.2 5-5c0-2.65-1.97-4.77-4.56-4.97zM7.82 15C7.4 16.15 6.28 17 5 17c-1.63 0-3-1.37-3-3s1.37-3 3-3c1.28 0 2.4.85 2.82 2H5v2h2.82zM19 17c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3z"/></svg>',
    offroad: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>',
    clasico: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>',
  };

  // ===== Helpers =====
  function formatPrice(n) {
    return '$' + (n || 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  }

  function statColor(val) {
    if (val >= 85) return '#a855f7';
    if (val >= 70) return '#3b82f6';
    if (val >= 50) return '#4ade80';
    if (val >= 30) return '#fbbf24';
    return '#ef4444';
  }

  function getCategoryLabel(value) {
    for (var i = 0; i < categories.length; i++) {
      if (categories[i].value === value) return categories[i].label;
    }
    return value;
  }

  function getClassLabel(cls) {
    var labels = { C: 'Clase C', B: 'Clase B', A: 'Clase A', S: 'Clase S' };
    return labels[cls] || cls;
  }

  // ===== Render Categories =====
  function renderCategories() {
    var html = '';
    // Count vehicles per category (only those in shopCategories)
    for (var i = 0; i < categories.length; i++) {
      var cat = categories[i];
      // Skip categories not sold in this shop (except "all")
      if (cat.value !== 'all') {
        var inShop = false;
        for (var s = 0; s < shopCategories.length; s++) {
          if (shopCategories[s] === cat.value) { inShop = true; break; }
        }
        if (!inShop) continue;
      }

      var count = 0;
      if (cat.value === 'all') {
        count = vehicles.length;
      } else {
        for (var v = 0; v < vehicles.length; v++) {
          if (vehicles[v].category === cat.value) count++;
        }
      }

      var icon = categoryIcons[cat.value] || categoryIcons.all;
      var active = currentCategory === cat.value ? ' active' : '';

      html += '<div class="category-tab' + active + '" data-category="' + cat.value + '">' +
        icon + cat.label +
        '<span class="category-count">' + count + '</span>' +
      '</div>';
    }

    els.sidebar.innerHTML = html;

    // Bind events
    $$('.category-tab').forEach(function (tab) {
      tab.addEventListener('click', function () {
        currentCategory = tab.dataset.category;
        $$('.category-tab').forEach(function (t) { t.classList.remove('active'); });
        tab.classList.add('active');
        filterAndSort();
      });
    });
  }

  // ===== Filter & Sort =====
  function filterAndSort() {
    var search = els.searchInput.value.toLowerCase().trim();

    filteredVehicles = vehicles.filter(function (v) {
      // Category filter
      if (currentCategory !== 'all' && v.category !== currentCategory) return false;

      // Search filter
      if (search) {
        var name = (v.label || '').toLowerCase();
        var model = (v.model || '').toLowerCase();
        if (name.indexOf(search) === -1 && model.indexOf(search) === -1) return false;
      }

      return true;
    });

    // Sort
    filteredVehicles.sort(function (a, b) {
      switch (currentSort) {
        case 'price-asc': return (a.price || 0) - (b.price || 0);
        case 'price-desc': return (b.price || 0) - (a.price || 0);
        case 'name-asc': return (a.label || '').localeCompare(b.label || '');
        case 'name-desc': return (b.label || '').localeCompare(a.label || '');
        default: return 0;
      }
    });

    renderVehicleGrid();
  }

  // ===== Render Vehicle Grid =====
  function renderVehicleGrid() {
    var html = '';

    if (filteredVehicles.length === 0) {
      html = '<div class="empty-state grid-empty">' +
        '<svg viewBox="0 0 24 24" fill="currentColor" style="width:48px;height:48px;color:rgba(255,255,255,0.08)">' +
          '<path d="M18.92 6.01C18.72 5.42 18.16 5 17.5 5h-11c-.66 0-1.21.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99z"/>' +
        '</svg>' +
        '<p>No se encontraron vehiculos</p>' +
      '</div>';
    } else {
      for (var i = 0; i < filteredVehicles.length; i++) {
        var v = filteredVehicles[i];
        var sel = v.model === selectedModel ? ' selected' : '';
        var cls = (v.class || 'C').toLowerCase();
        var stats = v.stats || { speed: 50, acceleration: 50, braking: 50, handling: 50 };

        html += '<div class="vehicle-card' + sel + '" data-model="' + v.model + '">' +
          '<div class="card-header">' +
            '<div class="vehicle-name">' + (v.label || 'Desconocido') + '</div>' +
            '<span class="class-badge class-' + cls + '">' + (v.class || 'C') + '</span>' +
          '</div>' +
          '<div class="card-badges">' +
            '<span class="category-badge">' + getCategoryLabel(v.category) + '</span>' +
          '</div>' +
          '<div class="price-tag">' + formatPrice(v.price) + '</div>' +
          '<div class="card-stats">' +
            '<div class="card-stat">' +
              '<span class="card-stat-label">' +
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>' +
                'VEL' +
              '</span>' +
              '<div class="card-stat-bar"><div class="card-stat-fill" style="width:' + stats.speed + '%;background:' + statColor(stats.speed) + '"></div></div>' +
            '</div>' +
            '<div class="card-stat">' +
              '<span class="card-stat-label">' +
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>' +
                'ACE' +
              '</span>' +
              '<div class="card-stat-bar"><div class="card-stat-fill" style="width:' + stats.acceleration + '%;background:' + statColor(stats.acceleration) + '"></div></div>' +
            '</div>' +
            '<div class="card-stat">' +
              '<span class="card-stat-label">' +
                '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>' +
                'FRE' +
              '</span>' +
              '<div class="card-stat-bar"><div class="card-stat-fill" style="width:' + stats.braking + '%;background:' + statColor(stats.braking) + '"></div></div>' +
            '</div>' +
          '</div>' +
        '</div>';
      }
    }

    els.vehicleGrid.innerHTML = html;
    els.gridCount.textContent = filteredVehicles.length + ' vehiculo' + (filteredVehicles.length !== 1 ? 's' : '');

    // Bind click events
    $$('.vehicle-card').forEach(function (card) {
      card.addEventListener('click', function () {
        selectVehicle(card.dataset.model);
      });
    });
  }

  // ===== Select Vehicle =====
  function selectVehicle(model) {
    selectedModel = model;
    var vehicle = null;

    for (var i = 0; i < vehicles.length; i++) {
      if (vehicles[i].model === model) {
        vehicle = vehicles[i];
        break;
      }
    }

    if (!vehicle) return;

    // Update card selection
    $$('.vehicle-card').forEach(function (c) {
      c.classList.toggle('selected', c.dataset.model === model);
    });

    // Show detail
    els.detailEmpty.style.display = 'none';
    els.detailContent.style.display = 'flex';

    var stats = vehicle.stats || { speed: 50, acceleration: 50, braking: 50, handling: 50 };
    var cls = (vehicle.class || 'C').toLowerCase();

    els.detailName.textContent = vehicle.label || 'Desconocido';
    els.detailCategory.textContent = getCategoryLabel(vehicle.category);
    els.detailClass.className = 'class-badge class-' + cls;
    els.detailClass.textContent = vehicle.class || 'C';
    els.detailPrice.textContent = formatPrice(vehicle.price);

    // Seats (estimate based on category)
    var seats = 4;
    if (vehicle.category === 'moto') seats = 2;
    else if (vehicle.category === 'super' || vehicle.category === 'deportivo') seats = 2;
    else if (vehicle.category === 'suv') seats = 4;
    if (vehicle.seats) seats = vehicle.seats;
    els.detailSeatsValue.textContent = seats;

    // Stats
    els.statSpeed.textContent = stats.speed;
    els.statSpeedFill.style.width = stats.speed + '%';
    els.statSpeedFill.style.background = statColor(stats.speed);

    els.statAccel.textContent = stats.acceleration;
    els.statAccelFill.style.width = stats.acceleration + '%';
    els.statAccelFill.style.background = statColor(stats.acceleration);

    els.statBrake.textContent = stats.braking;
    els.statBrakeFill.style.width = stats.braking + '%';
    els.statBrakeFill.style.background = statColor(stats.braking);

    els.statHandling.textContent = stats.handling;
    els.statHandlingFill.style.width = stats.handling + '%';
    els.statHandlingFill.style.background = statColor(stats.handling);

    // Info rows
    els.detailCatValue.textContent = getCategoryLabel(vehicle.category);
    els.detailClassValue.textContent = getClassLabel(vehicle.class);

    // Test drive button visibility
    els.btnTestdrive.style.display = enableTestDrive ? '' : 'none';

    // NUI callback
    sendNUI('selectVehicle', { model: model });
  }

  // ===== Show / Hide =====
  function showShop(data) {
    vehicles = data.vehicles || [];
    categories = data.categories || [];
    shopCategories = data.shopCategories || [];
    isDealer = data.isDealer || false;
    sellingTo = data.sellingTo || null;
    enableTestDrive = data.enableTestDrive !== false;
    selectedModel = null;
    currentCategory = 'all';

    els.shopName.textContent = data.shopName || 'Concesionario';
    els.searchInput.value = '';
    els.sortDropdown.value = currentSort;

    // Apply theme
    if (data.theme) document.body.dataset.theme = data.theme;
    if (data.lightMode) document.body.classList.add('light-mode');
    else document.body.classList.remove('light-mode');

    // Selling badge
    if (sellingTo) {
      els.sellingBadge.classList.add('visible');
    } else {
      els.sellingBadge.classList.remove('visible');
    }

    // Pay method
    els.detailPayMethod.textContent = data.payFrom === 'cash' ? 'Efectivo' : 'Banco';

    // Reset detail
    els.detailEmpty.style.display = '';
    els.detailContent.style.display = 'none';

    // Render categories
    renderCategories();

    // Filter and render
    filterAndSort();

    // Show
    els.overlay.style.display = 'block';
    els.container.style.display = '';
    els.container.classList.remove('hiding');

    requestAnimationFrame(function () {
      els.overlay.classList.add('visible');
      els.container.classList.add('visible');
    });
  }

  function hideShop() {
    els.overlay.classList.remove('visible');
    els.container.classList.add('hiding');
    els.container.classList.remove('visible');

    setTimeout(function () {
      els.overlay.style.display = 'none';
      els.container.style.display = 'none';
      els.container.classList.remove('hiding');
    }, 300);
  }

  // ===== Event Listeners =====

  // Close button
  els.closeBtn.addEventListener('click', function () {
    sendNUI('closeShop', {});
    hideShop();
  });

  // Back button (detail panel)
  els.btnBack.addEventListener('click', function () {
    selectedModel = null;
    els.detailEmpty.style.display = '';
    els.detailContent.style.display = 'none';
    $$('.vehicle-card').forEach(function (c) { c.classList.remove('selected'); });
  });

  // ESC key
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      if (els.confirmModal.classList.contains('visible')) {
        els.confirmModal.classList.remove('visible');
        confirmModel = null;
        return;
      }
      sendNUI('closeShop', {});
      hideShop();
    }
  });

  // Search
  els.searchInput.addEventListener('input', function () {
    filterAndSort();
  });

  // Sort
  els.sortDropdown.addEventListener('change', function () {
    currentSort = els.sortDropdown.value;
    filterAndSort();
  });

  // Buy button -> show confirm
  els.btnBuy.addEventListener('click', function () {
    if (!selectedModel) return;

    var vehicle = null;
    for (var i = 0; i < vehicles.length; i++) {
      if (vehicles[i].model === selectedModel) { vehicle = vehicles[i]; break; }
    }
    if (!vehicle) return;

    confirmModel = selectedModel;
    els.confirmDesc.textContent = '¿Comprar ' + vehicle.label + ' por ' + formatPrice(vehicle.price) + '?';
    els.confirmPrice.textContent = formatPrice(vehicle.price);
    els.confirmModal.classList.add('visible');
  });

  // Confirm buy
  els.btnConfirmBuy.addEventListener('click', function () {
    if (!confirmModel) return;
    sendNUI('buyVehicle', { model: confirmModel });
    els.confirmModal.classList.remove('visible');
    confirmModel = null;
  });

  // Cancel buy
  els.btnCancelBuy.addEventListener('click', function () {
    els.confirmModal.classList.remove('visible');
    confirmModel = null;
  });

  // Test drive button
  els.btnTestdrive.addEventListener('click', function () {
    if (!selectedModel) return;
    sendNUI('testDrive', { model: selectedModel });
  });

  // ===== NUI Communication =====
  function sendNUI(endpoint, data) {
    if (IS_BROWSER) {
      return;
    }
    fetch('https://dei_vehicleshop/' + endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
  }

  // ===== Message Handler =====
  window.addEventListener('message', function (event) {
    var d = event.data;
    switch (d.action) {
      case 'openShop':
        showShop(d);
        break;

      case 'closeShop':
        hideShop();
        break;

      case 'updateTheme':
        if (d.theme) document.body.dataset.theme = d.theme;
        if (d.lightMode) document.body.classList.add('light-mode');
        else document.body.classList.remove('light-mode');
        break;

      case 'showConfirm':
        if (d.model) {
          var vehicle = null;
          for (var i = 0; i < vehicles.length; i++) {
            if (vehicles[i].model === d.model) { vehicle = vehicles[i]; break; }
          }
          if (vehicle) {
            confirmModel = d.model;
            els.confirmDesc.textContent = '¿Comprar ' + vehicle.label + ' por ' + formatPrice(vehicle.price) + '?';
            els.confirmPrice.textContent = formatPrice(vehicle.price);
            els.confirmModal.classList.add('visible');
          }
        }
        break;

      case 'startTestDrive':
        els.testDriveTimer.classList.add('visible');
        els.timerValue.textContent = (d.time || 60) + 's';
        els.timerVehicle.textContent = d.vehicleName || '';
        break;

      case 'updateTestDriveTimer':
        els.timerValue.textContent = (d.time || 0) + 's';
        if (d.time <= 10) {
          els.timerValue.style.color = '#ef4444';
        } else {
          els.timerValue.style.color = '';
        }
        break;

      case 'endTestDrive':
        els.testDriveTimer.classList.remove('visible');
        els.timerValue.style.color = '';
        break;
    }
  });

  // ===== PREVIEW / DEMO MODE =====
  if (IS_BROWSER) {
    document.addEventListener('DOMContentLoaded', function () {
      document.body.style.background = 'linear-gradient(135deg, #0a0a1a 0%, #1a1a3a 50%, #0d0d20 100%)';
      document.body.style.visibility = 'visible';
      document.body.dataset.theme = 'dark';

      setTimeout(function () {
        var mockVehicles = [
          { model: 'sultan', label: 'Sultan', price: 25000, category: 'sedan', class: 'B',
            stats: { speed: 70, acceleration: 65, braking: 60, handling: 72 } },
          { model: 'schafter2', label: 'Schafter V12', price: 45000, category: 'sedan', class: 'A',
            stats: { speed: 78, acceleration: 72, braking: 68, handling: 74 } },
          { model: 'tailgater', label: 'Tailgater', price: 35000, category: 'sedan', class: 'B',
            stats: { speed: 72, acceleration: 68, braking: 65, handling: 70 } },
          { model: 'elegy2', label: 'Elegy RH8', price: 95000, category: 'deportivo', class: 'A',
            stats: { speed: 82, acceleration: 80, braking: 75, handling: 85 } },
          { model: 'jester', label: 'Jester', price: 120000, category: 'deportivo', class: 'A',
            stats: { speed: 85, acceleration: 82, braking: 78, handling: 80 } },
          { model: 'comet2', label: 'Comet', price: 110000, category: 'deportivo', class: 'A',
            stats: { speed: 83, acceleration: 78, braking: 80, handling: 82 } },
          { model: 'adder', label: 'Adder', price: 1000000, category: 'super', class: 'S',
            stats: { speed: 95, acceleration: 88, braking: 82, handling: 78 } },
          { model: 'zentorno', label: 'Zentorno', price: 750000, category: 'super', class: 'S',
            stats: { speed: 92, acceleration: 90, braking: 80, handling: 82 } },
          { model: 't20', label: 'T20', price: 1200000, category: 'super', class: 'S',
            stats: { speed: 96, acceleration: 92, braking: 85, handling: 80 } },
          { model: 'baller', label: 'Baller', price: 60000, category: 'suv', class: 'B',
            stats: { speed: 68, acceleration: 60, braking: 55, handling: 62 } },
          { model: 'granger', label: 'Granger', price: 45000, category: 'suv', class: 'C',
            stats: { speed: 60, acceleration: 55, braking: 50, handling: 58 } },
          { model: 'bati', label: 'Bati 801', price: 30000, category: 'moto', class: 'A',
            stats: { speed: 88, acceleration: 90, braking: 70, handling: 75 } },
          { model: 'hakuchou', label: 'Hakuchou', price: 55000, category: 'moto', class: 'A',
            stats: { speed: 90, acceleration: 85, braking: 65, handling: 70 } },
          { model: 'blista', label: 'Blista', price: 15000, category: 'compacto', class: 'C',
            stats: { speed: 55, acceleration: 58, braking: 60, handling: 65 } },
          { model: 'bifta', label: 'Bifta', price: 22000, category: 'offroad', class: 'C',
            stats: { speed: 58, acceleration: 60, braking: 50, handling: 68 } },
          { model: 'tornado', label: 'Tornado', price: 28000, category: 'clasico', class: 'C',
            stats: { speed: 50, acceleration: 48, braking: 52, handling: 55 } },
        ];

        var mockCategories = [
          { value: 'all', label: 'Todos' },
          { value: 'sedan', label: 'Sedanes' },
          { value: 'deportivo', label: 'Deportivos' },
          { value: 'super', label: 'Super' },
          { value: 'suv', label: 'SUV' },
          { value: 'compacto', label: 'Compactos' },
          { value: 'moto', label: 'Motos' },
          { value: 'offroad', label: 'Offroad' },
          { value: 'clasico', label: 'Clasicos' },
        ];

        window.postMessage({
          action: 'openShop',
          vehicles: mockVehicles,
          categories: mockCategories,
          shopCategories: ['sedan', 'deportivo', 'super', 'suv', 'compacto', 'moto', 'offroad', 'clasico'],
          shopName: 'Premium Deluxe Motorsport',
          isDealer: false,
          sellingTo: null,
          enableTestDrive: true,
          theme: 'dark',
          lightMode: false,
          payFrom: 'bank',
        });

        // Auto-select first vehicle
        setTimeout(function () {
          selectVehicle('adder');
        }, 100);
      }, 300);
    });
  }
})();
