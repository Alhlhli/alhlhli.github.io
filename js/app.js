/**
 * ===================================================================
 * التطبيق التفاعلي الموحد للموقع والمستودع الرقمي
 * م. عامر الحلحلي (Amer Al-Hlhli) - https://alhlhli.github.io/
 * يدعم الصفحة الرئيسية المختصة وكافة الصفحات المستقلة
 * ===================================================================
 */

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initNavbar();
  renderCurrentPage();
  initFilterAndSearch();
  initBackToTop();
  initModalListeners();
});

/* ===================================================================
   1. إدارة المظهر (Dark / Light Mode)
   =================================================================== */
function initTheme() {
  const themeToggleBtn = document.getElementById('themeToggleBtn');
  const savedTheme = localStorage.getItem('amer_theme') || 'dark';
  applyTheme(savedTheme);

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', () => {
      const currentTheme = document.documentElement.getAttribute('data-theme') || 'dark';
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      applyTheme(newTheme);
      localStorage.setItem('amer_theme', newTheme);
    });
  }
}

function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  const themeToggleBtn = document.getElementById('themeToggleBtn');
  if (themeToggleBtn) {
    const icon = themeToggleBtn.querySelector('i');
    if (icon) {
      icon.className = theme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
    }
  }
}

/* ===================================================================
   2. شريط التنقل (Navbar)
   =================================================================== */
function initNavbar() {
  const header = document.querySelector('.site-header');
  const mobileToggle = document.getElementById('mobileMenuToggle');
  const navLinks = document.querySelector('.nav-links');

  window.addEventListener('scroll', () => {
    if (window.scrollY > 30) {
      header?.classList.add('scrolled');
    } else {
      header?.classList.remove('scrolled');
    }
  });

  if (mobileToggle && navLinks) {
    mobileToggle.addEventListener('click', () => {
      navLinks.classList.toggle('mobile-open');
      const icon = mobileToggle.querySelector('i');
      if (icon) {
        icon.className = navLinks.classList.contains('mobile-open') ? 'fas fa-times' : 'fas fa-bars';
      }
    });

    navLinks.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        navLinks.classList.remove('mobile-open');
        const icon = mobileToggle.querySelector('i');
        if (icon) icon.className = 'fas fa-bars';
      });
    });
  }
}

/* ===================================================================
   2.5. القائمة المنسدلة لروابط المنتديات (Forum Links Dropdown)
   الشارقة سوفت - المشاغب - زيزووم
   =================================================================== */
function renderForumDropdownHtml(item, customLabel) {
  if (!item) return '';

  const label = customLabel || 'قراءة الموضوع كاملاً في المنتدى';
  const forumsList = [];

  // فحص كائن المنتديات المتعددة
  if (item.forums && typeof item.forums === 'object') {
    if (item.forums.sharjah) {
      forumsList.push({
        key: 'sharjah',
        name: 'منتديات الشارقة سوفت',
        shortName: 'الشارقة سوفت',
        icon: 'fas fa-shield-alt',
        url: item.forums.sharjah
      });
    }
    if (item.forums.absba) {
      forumsList.push({
        key: 'absba',
        name: 'منتديات المشاغب',
        shortName: 'المشاغب',
        icon: 'fas fa-users-cog',
        url: item.forums.absba
      });
    }
    if (item.forums.zyzoom) {
      forumsList.push({
        key: 'zyzoom',
        name: 'منتدى زيزووم للأمن والحماية',
        shortName: 'منتدى زيزووم',
        icon: 'fas fa-shield-virus',
        url: item.forums.zyzoom
      });
    }
  }

  // في حال لم يتوفر كائن forums ولكن يوجد رابط forumUrl
  if (forumsList.length === 0 && item.forumUrl) {
    let name = 'منتديات الشارقة سوفت';
    let shortName = 'الشارقة سوفت';
    let icon = 'fas fa-shield-alt';
    let key = 'sharjah';

    if (item.forumUrl.includes('absba.cc')) {
      name = 'منتديات المشاغب';
      shortName = 'المشاغب';
      icon = 'fas fa-users-cog';
      key = 'absba';
    } else if (item.forumUrl.includes('zyzoom.net')) {
      name = 'منتدى زيزووم للأمن والحماية';
      shortName = 'منتدى زيزووم';
      icon = 'fas fa-shield-virus';
      key = 'zyzoom';
    }

    forumsList.push({
      key: key,
      name: name,
      shortName: shortName,
      icon: icon,
      url: item.forumUrl
    });
  }

  if (forumsList.length === 0) return '';

  const itemsHtml = forumsList.map(f => `
    <a href="${escapeHtml(f.url)}" target="_blank" rel="noopener" class="forum-dropdown-item forum-item-${f.key}" role="menuitem" title="فتح الموضوع في ${escapeHtml(f.name)}">
      <div class="forum-item-title">
        <i class="${f.icon}"></i>
        <span>${escapeHtml(f.name)}</span>
      </div>
      <i class="fas fa-external-link-alt forum-item-ext"></i>
    </a>
  `).join('');

  return `
    <div class="forum-dropdown-wrapper">
      <button type="button" class="btn btn-forum-dropdown" onclick="toggleForumDropdown(this, event)" aria-haspopup="true" aria-expanded="false" title="قراءة الموضوع في المنتديات">
        <i class="fas fa-comments"></i>
        <span>${escapeHtml(label)}</span>
        <span class="forum-count-badge">${forumsList.length}</span>
        <i class="fas fa-chevron-down drop-arrow"></i>
      </button>
      <div class="forum-dropdown-menu" role="menu">
        <div class="forum-dropdown-header">
          <i class="fas fa-layer-group"></i> اختر المنتدى للمتابعة:
        </div>
        ${itemsHtml}
      </div>
    </div>
  `;
}

function toggleForumDropdown(button, event) {
  if (event) {
    event.stopPropagation();
    event.preventDefault();
  }
  const wrapper = button.closest('.forum-dropdown-wrapper');
  if (!wrapper) return;

  const isOpen = wrapper.classList.contains('open');

  // إغلاق أي قوائم أخرى مفتوحة في الصفحة
  document.querySelectorAll('.forum-dropdown-wrapper.open').forEach(el => {
    if (el !== wrapper) {
      el.classList.remove('open');
      const btn = el.querySelector('.btn-forum-dropdown');
      if (btn) btn.setAttribute('aria-expanded', 'false');
    }
  });

  if (isOpen) {
    wrapper.classList.remove('open');
    button.setAttribute('aria-expanded', 'false');
  } else {
    wrapper.classList.add('open');
    button.setAttribute('aria-expanded', 'true');
  }
}

// إغلاق القوائم عند النقر في أي مكان خارجها
document.addEventListener('click', (e) => {
  if (!e.target.closest('.forum-dropdown-wrapper')) {
    document.querySelectorAll('.forum-dropdown-wrapper.open').forEach(el => {
      el.classList.remove('open');
      const btn = el.querySelector('.btn-forum-dropdown');
      if (btn) btn.setAttribute('aria-expanded', 'false');
    });
  }
});

window.renderForumDropdownHtml = renderForumDropdownHtml;
window.toggleForumDropdown = toggleForumDropdown;

/* ===================================================================
   3. توليد المحتوى حسب الصفحة الحالية (Page-Specific Rendering)
   =================================================================== */
function renderCurrentPage() {
  if (!window.SITE_DATA) return;
  const data = window.SITE_DATA;

  // إذا كنا في صفحة الليسبات المستقلة
  if (document.getElementById('lispsFullGrid')) {
    renderFullLisps(data.lisps);
  }

  // إذا كنا في صفحة المشاريع الهندسية المستقلة
  if (document.getElementById('engineeringFullGrid')) {
    renderFullEngineering(data.engineeringProjects);
  }

  // إذا كنا في صفحة نسخ الويندوز المستقلة
  if (document.getElementById('windowsFullGrid')) {
    renderFullWindows(data.windows);
  }

  // إذا كنا في صفحة البرامج والمشاريع المستقلة
  if (document.getElementById('programsFullGrid')) {
    renderFullPrograms(data.programs);
  }

  // إذا كنا في صفحة قنوات التليجرام المستقلة
  if (document.getElementById('telegramFullGrid')) {
    renderFullTelegram(data.telegramChannels);
  }

  // إذا كنا في صفحة المقالات المستقلة
  if (document.getElementById('articlesFullGrid')) {
    renderFullArticles(data.articles);
  }

  // إذا كنا في صفحة الصفحات والمنصات الإسلامية المستقلة
  if (document.getElementById('islamicFullGrid')) {
    renderFullIslamic(data.islamic);
  }

  // إذا كنا في صفحة تعريب البرامج المستقلة
  if (document.getElementById('localizationFullGrid')) {
    renderFullLocalization(data.localizations);
  }

  // إذا كنا في صفحة شروحات وفيديوهات اليوتيوب المستقلة
  if (document.getElementById('youtubeVideosGrid') || document.getElementById('youtubePlaylistsGrid')) {
    renderFullYouTube(data.youtubeVideos, data.youtubePlaylists);
  }
}

// 00. توليد البرامج المعربة في localization.html
function renderFullLocalization(items) {
  const container = document.getElementById('localizationFullGrid');
  if (!container || !items) return;

  container.innerHTML = items.map(loc => {
    const badgeClass = `badge-${loc.badgeType || 'primary'}`;
    const featuresHtml = loc.features ? loc.features.map(f => `
      <li><i class="fas fa-check-circle" style="color:var(--accent-emerald);"></i> <span>${escapeHtml(f)}</span></li>
    `).join('') : '';

    return `
      <div class="custom-card item-card" data-category="${escapeHtml((loc.category || '') + ' ' + (loc.originalName || '') + ' ' + (loc.title || ''))}" data-id="${loc.id}">
        <span class="card-badge ${badgeClass}"><i class="${loc.icon || 'fas fa-language'}"></i> ${escapeHtml(loc.badge || 'برنامج معرب')}</span>
        
        ${loc.image ? `
          <div class="card-image-box" onclick="openImageModal('${loc.image}', '${escapeHtml(loc.title)}', '${loc.officialProofUrl ? escapeHtml(loc.officialProofUrl) : ''}')" title="انقر لتكبير صورة وإثبات التعريب">
            <img src="${loc.image}" alt="${escapeHtml(loc.title)}" loading="lazy" class="card-preview-thumb">
            <div class="image-zoom-overlay"><i class="fas fa-search-plus"></i> تكبير وإثبات التعريب</div>
          </div>
        ` : ''}

        <div class="card-header-area">
          <span class="category-tag">${escapeHtml(loc.category)}</span>
          <h3 class="card-title">${escapeHtml(loc.title)}</h3>
          <span class="card-subtitle"><i class="fas fa-globe"></i> ${escapeHtml(loc.originalName || '')} ${loc.version ? `• ${escapeHtml(loc.version)}` : ''}</span>
        </div>

        ${loc.officialCredit ? `
          <div class="official-credit-box">
            <i class="fas fa-award"></i> <span>${escapeHtml(loc.officialCredit)}</span>
          </div>
        ` : ''}

        <p class="card-description">${escapeHtml(loc.description)}</p>

        <ul class="features-list">
          ${featuresHtml}
        </ul>

        ${loc.installGuide ? `
          <div class="usage-note" style="margin: 0.75rem 0 1rem; font-size: 0.85rem;">
            <i class="fas fa-info-circle"></i> <strong>طريقة التثبيت:</strong> ${escapeHtml(loc.installGuide)}
          </div>
        ` : ''}

        <div class="card-footer-actions">
          ${loc.officialProofUrl ? `
            <a href="${loc.officialProofUrl}" target="_blank" rel="noopener" class="btn btn-proof btn-sm" title="فتح صفحة التوثيق الرسمية في الموقع الأصلي">
              <i class="fas fa-certificate"></i> إثبات التعريب الرسمي
            </a>
          ` : ''}
          ${renderForumDropdownHtml(loc)}
          <a href="${loc.telegramUrl || 'https://t.me/pro3mer'}" target="_blank" rel="noopener" class="btn btn-telegram btn-sm">
            <i class="fab fa-telegram-plane"></i> تحميل التعريب من @pro3mer
          </a>
        </div>
      </div>
    `;
  }).join('');
}

// 0. توليد الصفحات والمنصات الإسلامية في islamic.html
function renderFullIslamic(items) {
  const container = document.getElementById('islamicFullGrid');
  if (!container || !items) return;

  container.innerHTML = items.map(item => {
    const isLive = item.liveUrl && item.liveUrl.length > 0;
    const isGithub = item.githubUrl && item.githubUrl.length > 0;
    const isTelegram = item.id === 'quran-telegram';

    return `
      <div class="custom-card item-card" data-category="${escapeHtml(item.category)}" data-id="${item.id}">
        <span class="card-badge badge-success"><i class="fas fa-star"></i> ${escapeHtml(item.badge || 'مشروع')}</span>
        
        <div class="card-header-area">
          <span class="category-tag"><i class="fas fa-quran"></i> ${escapeHtml(item.category)}</span>
          <h3 class="card-title">${escapeHtml(item.title)}</h3>
          <span class="card-subtitle">${escapeHtml(item.subtitle || '')}</span>
        </div>

        <p class="card-description">${escapeHtml(item.description)}</p>

        ${item.features ? `
          <ul class="features-list">
            ${item.features.map(f => `<li><i class="fas fa-check-circle" style="color:var(--accent-emerald);"></i> <span>${escapeHtml(f)}</span></li>`).join('')}
          </ul>
        ` : ''}

        <div class="card-footer-actions">
          ${isLive && !isTelegram ? `
            <a href="${item.liveUrl}" target="_blank" rel="noopener" class="btn btn-primary btn-sm">
              <i class="fas fa-external-link-alt"></i> فتح المنصة المباشرة
            </a>
          ` : ''}
          ${isGithub ? `
            <a href="${item.githubUrl}" target="_blank" rel="noopener" class="btn btn-outline btn-sm">
              <i class="fab fa-github"></i> مستودع GitHub
            </a>
          ` : ''}
          ${isTelegram ? `
            <a href="${item.liveUrl}" target="_blank" rel="noopener" class="btn btn-telegram btn-sm" style="width:100%;">
              <i class="fab fa-telegram-plane"></i> الاشتراك بقناة القرآن على تليجرام
            </a>
          ` : ''}
          ${renderForumDropdownHtml(item)}
        </div>
      </div>
    `;
  }).join('');
}

// 1. توليد الليسبات في صفحة lisps.html
function renderFullLisps(items) {
  const container = document.getElementById('lispsFullGrid');
  if (!container || !items) return;

  container.innerHTML = items.map(lisp => {
    return `
      <div class="custom-card item-card" data-category="${escapeHtml(lisp.category)}" data-id="${lisp.id}">
        <div>
          <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 0.75rem;">
            <span class="lisp-command-badge">
              <i class="fas fa-terminal"></i> أمر: ${escapeHtml(lisp.command)}
            </span>
            <span class="category-tag">${escapeHtml(lisp.category)}</span>
          </div>

          <h3 class="card-title">${escapeHtml(lisp.name)}</h3>
          <p class="card-description">${escapeHtml(lisp.description)}</p>

          <div class="usage-note">
            <i class="fas fa-info-circle"></i> <strong>طريقة الاستخدام:</strong> ${escapeHtml(lisp.usage)}
          </div>
          ${lisp.folder ? `<div style="font-size:0.8rem; color:var(--text-dim); margin-bottom:0.75rem;"><i class="fas fa-folder"></i> المجلد: ${escapeHtml(lisp.folder)}</div>` : ''}
        </div>

        <div class="card-footer-actions">
          <button class="btn btn-primary btn-sm" onclick="openLispModal('${lisp.id}')">
            <i class="fas fa-code"></i> عرض التفاصيل والأمر
          </button>
          <a href="https://t.me/pro3mer" target="_blank" rel="noopener" class="btn btn-telegram btn-sm">
            <i class="fab fa-telegram-plane"></i> قناة pro3mer
          </a>
        </div>
      </div>
    `;
  }).join('');
}

// 2. توليد المشاريع الهندسية في engineering.html
function renderFullEngineering(items) {
  const container = document.getElementById('engineeringFullGrid');
  if (!container || !items) return;

  container.innerHTML = items.map(proj => {
    return `
      <div class="custom-card item-card" data-category="${escapeHtml(proj.role)}" data-id="${proj.id}">
        <div>
          <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 0.5rem;">
            <span class="card-badge badge-primary"><i class="fas fa-calendar-alt"></i> ${escapeHtml(proj.year)}</span>
            <span class="category-tag"><i class="fas fa-map-marker-alt"></i> ${escapeHtml(proj.location)}</span>
          </div>

          <h3 class="card-title">${escapeHtml(proj.title)}</h3>
          
          <div class="card-specs-row" style="margin: 0.75rem 0;">
            <span class="spec-pill"><i class="fas fa-user-tie"></i> <strong>الدور:</strong> ${escapeHtml(proj.role)}</span>
            <span class="spec-pill"><i class="fas fa-building"></i> <strong>الجهة:</strong> ${escapeHtml(proj.client)}</span>
          </div>

          <p class="card-description">${escapeHtml(proj.description)}</p>
        </div>

        <div class="card-footer-actions">
          <span style="font-size:0.85rem; color:var(--accent-emerald);">
            <i class="fas fa-check-circle"></i> مشروع منجز باحترافية
          </span>
          <a href="https://wa.me/966504667646?text=استفسار_عن_مشروع_${encodeURIComponent(proj.title)}" target="_blank" rel="noopener" class="btn btn-outline btn-sm">
            <i class="fab fa-whatsapp"></i> تواصل بشأن المشروع
          </a>
        </div>
      </div>
    `;
  }).join('');
}

// 3. توليد نسخ الويندوز في windows.html
function renderFullWindows(items) {
  const container = document.getElementById('windowsFullGrid');
  if (!container || !items) return;

  container.innerHTML = items.map(win => {
    const badgeClass = `badge-${win.badgeType || 'primary'}`;
    const featuresHtml = win.features ? win.features.map(f => `
      <li><i class="fas fa-check-circle"></i> <span>${escapeHtml(f)}</span></li>
    `).join('') : '';

    return `
      <div class="custom-card item-card" data-category="${escapeHtml((win.category || '') + ' ' + win.title + ' ' + (win.version || '') + ' ' + (win.badge || ''))}" data-id="${win.id}">
        <span class="card-badge ${badgeClass}">${escapeHtml(win.badge || 'نسخة معدلة')}</span>
        <div class="card-header-area">
          <h3 class="card-title">${escapeHtml(win.title)}</h3>
          <span class="card-subtitle">${escapeHtml(win.subtitle || '')}</span>
        </div>

        <div class="card-specs-row">
          <span class="spec-pill"><i class="fas fa-microchip"></i> ${escapeHtml(win.architecture || 'x64')}</span>
          <span class="spec-pill"><i class="fas fa-compact-disc"></i> ${escapeHtml(win.isoSize || '3.5 GB')}</span>
          <span class="spec-pill"><i class="fas fa-memory"></i> ${escapeHtml(win.ramUsage || 'مخفف')}</span>
        </div>

        <p class="card-description">${escapeHtml(win.description)}</p>

        <ul class="features-list">
          ${featuresHtml}
        </ul>

        <div class="card-footer-actions">
          ${renderForumDropdownHtml(win)}
          <a href="${win.telegramUrl || 'https://t.me/pro3mer'}" target="_blank" rel="noopener" class="btn btn-telegram btn-sm">
            <i class="fab fa-telegram-plane"></i> قناة التليجرام
          </a>
        </div>
      </div>
    `;
  }).join('');
}

// 4. توليد البرامج في programs.html
function renderFullPrograms(items) {
  const container = document.getElementById('programsFullGrid');
  if (!container || !items) return;

  container.innerHTML = items.map(prog => {
    const isCreated = prog.programType === 'created';
    const typeBadgeClass = isCreated ? 'type-created' : 'type-tutorial';
    const typeIcon = isCreated ? 'fa-hammer' : 'fa-book-reader';
    const typeLabel = prog.typeLabel || (isCreated ? 'برنامج أنشأته أو عدلته' : 'شرح وموضوع برمجي');

    return `
      <div class="custom-card item-card" data-category="${escapeHtml(prog.category)}" data-type="${escapeHtml(prog.programType || '')}" data-id="${prog.id}">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 0.85rem; flex-wrap:wrap; gap:0.5rem;">
          <span class="program-type-badge ${typeBadgeClass}">
            <i class="fas ${typeIcon}"></i> ${escapeHtml(typeLabel)}
          </span>
          <span class="card-badge badge-primary" style="position:static; margin:0;">${escapeHtml(prog.badge || 'برنامج')}</span>
        </div>

        ${prog.image ? `
          <div class="card-image-box" onclick="openImageModal('${prog.image}', '${escapeHtml(prog.title)}', '${prog.forumUrl || prog.githubUrl || ''}')" title="انقر للمعاينة">
            <img src="${prog.image}" alt="${escapeHtml(prog.title)}" loading="lazy" class="card-preview-thumb">
            <div class="image-zoom-overlay"><i class="fas fa-search-plus"></i> تكبير الصورة</div>
          </div>
        ` : ''}

        <div class="card-header-area">
          <span class="category-tag">${escapeHtml(prog.category)}</span>
          <h3 class="card-title">${escapeHtml(prog.title)}</h3>
          <span class="card-subtitle"><i class="fas fa-code-branch"></i> ${escapeHtml(prog.tech || '')}</span>
        </div>

        <p class="card-description">${escapeHtml(prog.description)}</p>

        ${prog.features ? `
          <ul class="features-list">
            ${prog.features.slice(0, 3).map(f => `<li><i class="fas fa-check"></i> <span>${escapeHtml(f)}</span></li>`).join('')}
          </ul>
        ` : ''}

        <div class="card-footer-actions">
          ${prog.githubUrl ? `
            <a href="${prog.githubUrl}" target="_blank" rel="noopener" class="btn btn-outline btn-sm">
              <i class="fab fa-github"></i> مستودع GitHub
            </a>
          ` : ''}
          ${renderForumDropdownHtml(prog)}
          <a href="${prog.telegramUrl || 'https://t.me/pro3mer'}" target="_blank" rel="noopener" class="btn btn-telegram btn-sm">
            <i class="fab fa-telegram-plane"></i> التحميل عبر تليجرام
          </a>
        </div>
      </div>
    `;
  }).join('');
}

// 5. توليد قنوات التليجرام في telegram.html
function renderFullTelegram(items) {
  const container = document.getElementById('telegramFullGrid');
  if (!container || !items) return;

  container.innerHTML = items.map(tg => {
    return `
      <div class="telegram-card item-card" data-category="${escapeHtml(tg.category)}" data-id="${tg.id}">
        <div>
          <div class="tg-header">
            <div class="tg-avatar">
              <i class="${tg.icon || 'fab fa-telegram-plane'}"></i>
            </div>
            <div class="tg-info">
              <h4>${escapeHtml(tg.name)}</h4>
              <span class="tg-username">${escapeHtml(tg.username)}</span>
            </div>
          </div>

          <div class="tg-members-badge">
            <i class="fas fa-check-circle"></i> ${escapeHtml(tg.badge || 'قناة رسمية')}
          </div>

          <p class="card-description">${escapeHtml(tg.description)}</p>
        </div>

        <div class="card-footer-actions" style="margin-top:1.25rem;">
          <a href="${tg.link}" target="_blank" rel="noopener" class="btn ${tg.id === 'tg-youtube-channel' || (tg.icon && tg.icon.includes('youtube')) ? 'btn-youtube' : 'btn-telegram'}" style="width:100%;">
            <i class="${tg.icon || 'fab fa-telegram-plane'}"></i> ${tg.id === 'tg-youtube-channel' ? 'الاشتراك في قناة اليوتيوب' : 'الدخول للقناة / الرابط'}
          </a>
        </div>
      </div>
    `;
  }).join('');
}

// 6. توليد المقالات في articles.html
function renderFullArticles(items) {
  const container = document.getElementById('articlesFullGrid');
  if (!container || !items) return;

  container.innerHTML = items.map(art => {
    return `
      <div class="article-card item-card" data-category="${escapeHtml(art.category)}" data-id="${art.id}">
        <div>
          <div class="article-meta">
            <span><i class="far fa-calendar-alt"></i> ${escapeHtml(art.date)}</span>
            <span><i class="far fa-clock"></i> ${escapeHtml(art.readTime)}</span>
            <span class="category-tag" style="margin-bottom:0;">${escapeHtml(art.category)}</span>
          </div>

          <h3 class="article-title">${escapeHtml(art.title)}</h3>
          <p class="article-summary">${escapeHtml(art.summary)}</p>
          
          <div style="font-size:0.8rem; color:var(--accent-cyan); margin-bottom:1rem;">
            <i class="fas fa-globe"></i> المصدر: ${escapeHtml(art.sourceName || 'منتديات المشاغب والشارقة')}
          </div>
        </div>

        <div class="card-footer-actions">
          <button class="btn btn-primary btn-sm" onclick="openArticleModal('${art.id}')">
            <i class="fas fa-book-open"></i> قراءة المقال بالكامل
          </button>
          ${renderForumDropdownHtml(art)}
        </div>
      </div>
    `;
  }).join('');
}

// 3.5. توليد فيديوهات وقوائم تشغيل اليوتيوب في youtube.html
function renderFullYouTube(videos, playlists) {
  const playlistsContainer = document.getElementById('youtubePlaylistsGrid');
  const videosContainer = document.getElementById('youtubeVideosGrid');

  // توليد قوائم التشغيل الرسمية
  if (playlistsContainer && playlists) {
    playlistsContainer.innerHTML = playlists.map(pl => `
      <div class="custom-card yt-playlist-card" data-category="قائمة تشغيل playlist" data-id="${pl.id}">
        <span class="card-badge badge-youtube"><i class="fas fa-layer-group"></i> ${escapeHtml(pl.badge || 'سلسلة متكاملة')}</span>
        
        <div class="yt-thumb-wrapper" onclick="window.open('${escapeHtml(pl.url)}', '_blank')" title="فتح قائمة التشغيل على YouTube">
          <img src="${escapeHtml(pl.thumbnail)}" alt="${escapeHtml(pl.title)}" loading="lazy" class="yt-thumb-img">
          <div class="yt-playlist-count-badge">
            <i class="fas fa-play-circle"></i> ${escapeHtml(pl.videoCount)}
          </div>
          <div class="yt-play-overlay">
            <div class="yt-play-btn-circle"><i class="fas fa-play"></i></div>
            <span>تشغيل السلسلة في YouTube</span>
          </div>
        </div>

        <div class="card-header-area" style="margin-top: 1rem;">
          <span class="category-tag"><i class="fas fa-list-ol"></i> ${escapeHtml(pl.videoCount)}</span>
          <h3 class="card-title">${escapeHtml(pl.title)}</h3>
        </div>

        <p class="card-description">${escapeHtml(pl.description)}</p>

        <div class="card-footer-actions">
          <a href="${escapeHtml(pl.url)}" target="_blank" rel="noopener" class="btn btn-youtube btn-sm" style="width: 100%;">
            <i class="fab fa-youtube"></i> فتح القائمة بالكامل في YouTube (${escapeHtml(pl.videoCount)})
          </a>
        </div>
      </div>
    `).join('');
  }

  // توليد الفيديوهات الكاملة
  if (videosContainer && videos) {
    videosContainer.innerHTML = videos.map(v => `
      <div class="custom-card yt-video-card item-card" data-category="${escapeHtml((v.category || '') + ' ' + (v.title || '') + ' ' + (v.badge || ''))}" data-id="${v.id}">
        <span class="card-badge badge-youtube"><i class="fab fa-youtube"></i> ${escapeHtml(v.badge || 'شرح فيديو')}</span>

        <div class="yt-thumb-wrapper" onclick="openYouTubeModal('${v.id}')" title="انقر لمشاهدة الفيديو">
          <img src="${escapeHtml(v.thumbnail)}" alt="${escapeHtml(v.title)}" loading="lazy" class="yt-thumb-img">
          ${v.duration ? `<span class="yt-duration-badge">${escapeHtml(v.duration)}</span>` : ''}
          <div class="yt-play-overlay">
            <div class="yt-play-btn-circle"><i class="fas fa-play"></i></div>
            <span>مشاهدة الفيديو الآن</span>
          </div>
        </div>

        <div class="card-header-area" style="margin-top: 0.85rem;">
          <div style="display:flex; justify-content:space-between; align-items:center; width:100%; margin-bottom: 0.35rem; flex-wrap:wrap; gap:0.35rem;">
            <span class="category-tag">${escapeHtml(v.category)}</span>
            <div class="yt-meta-info">
              ${v.views ? `<span><i class="far fa-eye"></i> ${escapeHtml(v.views)}</span>` : ''}
              ${v.date ? `<span>• ${escapeHtml(v.date)}</span>` : ''}
            </div>
          </div>
          <h3 class="card-title" style="font-size: 1.05rem; line-height: 1.5; cursor:pointer;" onclick="openYouTubeModal('${v.id}')" title="تشغيل الفيديو">${escapeHtml(v.title)}</h3>
        </div>

        <p class="card-description" style="font-size: 0.88rem; line-height: 1.6;">${escapeHtml(v.description)}</p>

        <div class="card-footer-actions">
          <button type="button" class="btn btn-primary btn-sm" onclick="openYouTubeModal('${v.id}')" title="مشاهدة مباشرة داخل الموقع">
            <i class="fas fa-play"></i> مشاهدة مباشرة
          </button>
          <a href="${escapeHtml(v.url)}" target="_blank" rel="noopener" class="btn btn-youtube btn-sm" title="فتح ومشاهدة على YouTube">
            <i class="fab fa-youtube"></i> على YouTube
          </a>
        </div>
      </div>
    `).join('');
  }
}

/* ===================================================================
   4. الفلترة والبحث اللحظي (Filter & Search)
   =================================================================== */
function initFilterAndSearch() {
  const searchInput = document.getElementById('pageSearchInput');
  const filterBtns = document.querySelectorAll('.filter-btn');

  let currentCategory = 'all';
  let currentSearchQuery = '';

  filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      currentCategory = btn.getAttribute('data-filter') || 'all';
      applyFilterAndSearch();
    });
  });

  searchInput?.addEventListener('input', (e) => {
    currentSearchQuery = e.target.value.trim().toLowerCase();
    applyFilterAndSearch();
  });

  function applyFilterAndSearch() {
    const allCards = document.querySelectorAll('.item-card');
    let visibleCount = 0;
    const tokens = currentCategory === 'all' 
      ? [] 
      : currentCategory.split(',').map(t => t.trim().toLowerCase()).filter(Boolean);

    allCards.forEach(card => {
      const cardCategory = (card.getAttribute('data-category') || '').toLowerCase();
      const cardType = (card.getAttribute('data-type') || '').toLowerCase();
      const textContent = card.innerText.toLowerCase();

      let matchesCat = false;
      if (currentCategory === 'all') {
        matchesCat = true;
      } else if (currentCategory === 'created' || currentCategory === 'tutorial') {
        matchesCat = (cardType === currentCategory);
      } else {
        matchesCat = (tokens.length === 0 || tokens.some(t => cardCategory.includes(t)));
      }

      const matchesSearch = (currentSearchQuery === '' || textContent.includes(currentSearchQuery));

      if (matchesCat && matchesSearch) {
        card.style.display = 'flex';
        visibleCount++;
      } else {
        card.style.display = 'none';
      }
    });

    const noResults = document.querySelector('.no-results');
    if (noResults) {
      noResults.style.display = visibleCount === 0 ? 'block' : 'none';
    }
  }
}

/* ===================================================================
   5. النوافذ المنبثقة التفاعلية (Modals & Lightbox)
   =================================================================== */
function initModalListeners() {
  let modalOverlay = document.getElementById('detailsModal');
  if (!modalOverlay) {
    modalOverlay = document.createElement('div');
    modalOverlay.id = 'detailsModal';
    modalOverlay.className = 'modal-overlay';
    modalOverlay.setAttribute('role', 'dialog');
    modalOverlay.setAttribute('aria-modal', 'true');
    modalOverlay.setAttribute('aria-labelledby', 'modalTitle');
    modalOverlay.innerHTML = `
      <div class="modal-container">
        <div class="modal-header">
          <div id="modalTitle" class="modal-title">معاينة</div>
          <button id="modalCloseBtn" class="modal-close-btn" aria-label="إغلاق"><i class="fas fa-times"></i></button>
        </div>
        <div id="modalBody" class="modal-body"></div>
        <div id="modalFooter" class="modal-footer"></div>
      </div>
    `;
    document.body.appendChild(modalOverlay);
  }

  const closeBtn = document.getElementById('modalCloseBtn');
  closeBtn?.addEventListener('click', closeModal);
  modalOverlay?.addEventListener('click', (e) => {
    if (e.target === modalOverlay) closeModal();
  });
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeModal();
  });
}

function openModal(title, bodyHtml, footerButtonsHtml = '') {
  let modalOverlay = document.getElementById('detailsModal');
  if (!modalOverlay) {
    initModalListeners();
    modalOverlay = document.getElementById('detailsModal');
  }

  const modalTitle = document.getElementById('modalTitle');
  const modalBody = document.getElementById('modalBody');
  const modalFooter = document.getElementById('modalFooter');

  if (!modalOverlay || !modalTitle || !modalBody) return;

  modalTitle.innerHTML = title;
  modalBody.innerHTML = bodyHtml;
  
  if (modalFooter) {
    modalFooter.innerHTML = footerButtonsHtml || `
      <button class="btn btn-outline btn-sm" onclick="closeModal()">إغلاق</button>
    `;
  }

  modalOverlay.classList.add('active');
  document.body.style.overflow = 'hidden';
}

function closeModal() {
  const modalOverlay = document.getElementById('detailsModal');
  modalOverlay?.classList.remove('active');
  document.body.style.overflow = '';
  const modalBody = document.getElementById('modalBody');
  if (modalBody) modalBody.innerHTML = '';
}

function openImageModal(imageSrc, title, proofUrl = '') {
  const footerButtons = `
    ${proofUrl ? `
      <a href="${proofUrl}" target="_blank" rel="noopener" class="btn btn-primary btn-sm">
        <i class="fas fa-external-link-alt"></i> فتح رابط التوثيق الرسمي
      </a>
    ` : ''}
    <button class="btn btn-outline btn-sm" onclick="closeModal()">إغلاق المعاينة</button>
  `;

  const bodyHtml = `
    <div style="text-align:center;">
      <div style="background:rgba(0,0,0,0.25); border-radius:12px; padding:0.5rem; display:inline-block; max-width:100%; border:1px solid var(--border-color);">
        <img src="${imageSrc}" alt="${escapeHtml(title)}" style="max-width:100%; max-height:70vh; height:auto; display:block; margin:0 auto; border-radius:8px; object-fit:contain;">
      </div>
      <div style="margin-top:1rem; font-size:1.05rem; font-weight:700; color:var(--text-main);">
        ${escapeHtml(title)}
      </div>
      ${proofUrl ? `
        <div style="margin-top:0.5rem; font-size:0.85rem; color:var(--accent-cyan);">
          <i class="fas fa-certificate"></i> توثيق رسمي معتمد
        </div>
      ` : ''}
    </div>
  `;

  openModal(`<i class="fas fa-image"></i> معاينة الصورة والتوثيق الرسمي`, bodyHtml, footerButtons);
}

window.openImageModal = openImageModal;
window.openModal = openModal;
window.closeModal = closeModal;

function openLispModal(lispId) {
  const data = window.SITE_DATA;
  const lisp = data?.lisps?.find(l => l.id === lispId);
  if (!lisp) return;

  const bodyHtml = `
    <div style="margin-bottom:1rem;">
      <span class="lisp-command-badge" style="font-size:1.1rem; padding:0.4rem 1rem;">
        <i class="fas fa-terminal"></i> أمر التشغيل في أوتوكاد: ${escapeHtml(lisp.command)}
      </span>
      <h3 style="margin-top:0.75rem; color:var(--text-main);">${escapeHtml(lisp.name)}</h3>
      <p style="color:var(--text-muted); margin-top:0.5rem;">${escapeHtml(lisp.description)}</p>
    </div>

    <div class="usage-note" style="margin-top:1rem;">
      <strong><i class="fas fa-book-reader"></i> تعليمات التحميل والتشغيل:</strong><br>
      1. افتح برنامج الأوتوكاد واكتب أمر <code>APPLOAD</code> ثم اضغط Enter.<br>
      2. حدد ملف الليسب واضغط Load.<br>
      3. اكتب الأمر <code>${escapeHtml(lisp.command)}</code> في سطر الأوامر ونفذ الإجراء.
    </div>

    ${lisp.folder ? `
      <div style="background:rgba(255,255,255,0.03); padding:0.75rem; border-radius:8px; border:1px solid var(--border-color); margin-top:1rem;">
        <strong><i class="fas fa-folder-open"></i> مسار الملف في المجلد الأصلي:</strong><br>
        <code>D:\\ذكاء\\ليسبات\\${escapeHtml(lisp.folder)}</code>
      </div>
    ` : ''}
  `;

  const footerHtml = `
    <button class="btn btn-outline btn-sm" onclick="closeModal()">إغلاق</button>
    <a href="https://t.me/pro3mer" target="_blank" rel="noopener" class="btn btn-telegram btn-sm">
      <i class="fab fa-telegram-plane"></i> طلب أو تحميل من قناة pro3mer
    </a>
  `;

  openModal(`<i class="fas fa-drafting-compass" style="color:var(--accent-cyan)"></i> تفاصيل ليسب الأوتوكاد`, bodyHtml, footerHtml);
}

function openArticleModal(articleId) {
  const data = window.SITE_DATA;
  const article = data?.articles?.find(a => a.id === articleId);
  if (!article) return;

  const formattedContent = parseSimpleMarkdown(article.content || article.summary);

  const bodyHtml = `
    <div style="border-bottom:1px solid var(--border-color); padding-bottom:1rem; margin-bottom:1.5rem;">
      <span class="category-tag">${escapeHtml(article.category)}</span>
      <h2 style="font-size:1.5rem; line-height:1.4; color:var(--text-main); margin:0.5rem 0;">${escapeHtml(article.title)}</h2>
      <div class="article-meta">
        <span><i class="far fa-calendar-alt"></i> ${escapeHtml(article.date)}</span>
        <span><i class="far fa-clock"></i> ${escapeHtml(article.readTime)}</span>
        <span><i class="fas fa-user-edit"></i> بقلم: م. عامر الحلحلي</span>
      </div>
    </div>
    <div class="article-rich-text" style="font-size:1.05rem; line-height:1.9;">
      ${formattedContent}
    </div>
  `;

  const footerHtml = `
    <button class="btn btn-outline btn-sm" onclick="closeModal()">إغلاق</button>
    ${renderForumDropdownHtml(article)}
  `;

  openModal(`<i class="fas fa-book-open" style="color:var(--accent-purple)"></i> قراءة موضوع ومقال تقني`, bodyHtml, footerHtml);
}

function openYouTubeModal(videoId) {
  const data = window.SITE_DATA;
  const video = data?.youtubeVideos?.find(v => v.id === videoId);
  if (!video) return;

  const bodyHtml = `
    <div class="yt-modal-embed-wrapper">
      <iframe src="https://www.youtube-nocookie.com/embed/${videoId}?autoplay=1&rel=0" 
              title="${escapeHtml(video.title)}" 
              frameborder="0" 
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" 
              allowfullscreen></iframe>
    </div>
    <div style="margin-top: 1.25rem;">
      <div style="display:flex; gap:0.75rem; align-items:center; margin-bottom:0.6rem; flex-wrap:wrap;">
        <span class="category-tag">${escapeHtml(video.category)}</span>
        <span class="yt-meta-info" style="font-size:0.85rem; color:var(--text-dim);">
          ${video.views ? `<i class="far fa-eye"></i> ${escapeHtml(video.views)} مشاهدة` : ''} 
          ${video.date ? `• تاريخ النشر: ${escapeHtml(video.date)}` : ''} 
          ${video.duration ? `• المدة: ${escapeHtml(video.duration)}` : ''}
        </span>
      </div>
      <h2 style="font-size: 1.25rem; font-weight: 800; color: var(--text-main); margin-bottom: 0.75rem; line-height: 1.5;">${escapeHtml(video.title)}</h2>
      <p style="color: var(--text-muted); font-size: 0.95rem; line-height: 1.8;">${escapeHtml(video.description)}</p>
    </div>
  `;

  const footerHtml = `
    <button class="btn btn-outline btn-sm" onclick="closeModal()">إغلاق المشغل</button>
    <a href="${escapeHtml(video.url)}" target="_blank" rel="noopener" class="btn btn-youtube btn-sm">
      <i class="fab fa-youtube"></i> فتح ومتابعة على YouTube
    </a>
  `;

  openModal(`<i class="fab fa-youtube" style="color:#ff0000;"></i> مشغل فيديو YouTube`, bodyHtml, footerHtml);
}

/* ===================================================================
   6. أدوات مساعدة (Utilities)
   =================================================================== */
function initBackToTop() {
  const backToTopBtn = document.getElementById('backToTopBtn');
  if (!backToTopBtn) return;

  window.addEventListener('scroll', () => {
    if (window.scrollY > 400) {
      backToTopBtn.classList.add('show');
    } else {
      backToTopBtn.classList.remove('show');
    }
  });

  backToTopBtn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });
}

function showToast(message) {
  const toast = document.getElementById('toastNotification');
  const toastMsg = document.getElementById('toastMessage');
  if (!toast || !toastMsg) return;

  toastMsg.textContent = message;
  toast.classList.add('show');

  setTimeout(() => {
    toast.classList.remove('show');
  }, 3500);
}

function escapeHtml(text) {
  if (text === null || text === undefined) return '';
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function parseSimpleMarkdown(md) {
  if (!md) return '';
  let html = escapeHtml(md);
  html = html.replace(/^### (.*$)/gim, '<h3 style="color:var(--accent-cyan); margin:1.25rem 0 0.5rem;">$1</h3>');
  html = html.replace(/^## (.*$)/gim, '<h2 style="color:var(--text-main); margin:1.5rem 0 0.75rem;">$1</h2>');
  html = html.replace(/\*\*(.*?)\*\*/g, '<strong style="color:var(--accent-cyan);">$1</strong>');
  html = html.replace(/`([^`]+)`/g, '<code>$1</code>');
  html = html.replace(/\n\n/g, '<br><br>');
  return html;
}

window.openLispModal = openLispModal;
window.openArticleModal = openArticleModal;
window.openYouTubeModal = openYouTubeModal;
window.renderFullYouTube = renderFullYouTube;
window.closeModal = closeModal;
window.showToast = showToast;
