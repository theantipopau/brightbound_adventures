/**
 * BrightBound Adventures - Website JavaScript
 */

// Register Service Worker for offline support
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js').catch(err => {
            console.warn('Service Worker registration failed:', err);
        });
    });
}

document.addEventListener('DOMContentLoaded', function() {
    // Mobile Navigation Toggle
    initMobileNav();
    
    // FAQ Accordion
    initFAQ();
    
    // Smooth scrolling for anchor links
    initSmoothScroll();
    
    // Add scroll effects
    initScrollEffects();
    
    // Add keyboard accessibility
    initKeyboardNav();

    // Minor ambient motion and polish effects
    initAmbientPolish();

    // Form handling
    initFormHandling();

    // Phase 1: Visual Polish Enhancements
    initDarkMode();
    initEnhancedAnimations();
    initFormValidation();
    
    // Phase 2: Interactive Features
    initModals();
    initCarousel();
    initParallaxScroll();
    initLazyLoading();
    initProgressIndicator();
});

/**
 * Mobile Navigation
 */
function initMobileNav() {
    const navToggle = document.querySelector('.nav-toggle');
    const navMenu = document.querySelector('.nav-menu');
    
    if (navToggle && navMenu) {
        navToggle.addEventListener('click', function() {
            navToggle.classList.toggle('active');
            navMenu.classList.toggle('active');
        });
        
        // Close menu when clicking a link
        const navLinks = navMenu.querySelectorAll('.nav-link');
        navLinks.forEach(link => {
            link.addEventListener('click', function() {
                navToggle.classList.remove('active');
                navMenu.classList.remove('active');
            });
        });
        
        // Close menu when clicking outside
        document.addEventListener('click', function(e) {
            if (!navToggle.contains(e.target) && !navMenu.contains(e.target)) {
                navToggle.classList.remove('active');
                navMenu.classList.remove('active');
            }
        });
    }
}

/**
 * FAQ Accordion
 */
function initFAQ() {
    const faqItems = document.querySelectorAll('.faq-item');
    
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        
        if (question) {
            question.addEventListener('click', function() {
                // Close other items
                faqItems.forEach(otherItem => {
                    if (otherItem !== item && otherItem.classList.contains('active')) {
                        otherItem.classList.remove('active');
                    }
                });
                
                // Toggle current item
                item.classList.toggle('active');
            });
        }
    });
}

/**
 * Smooth Scrolling
 */
function initSmoothScroll() {
    const links = document.querySelectorAll('a[href^="#"]');
    
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            
            if (href !== '#') {
                const target = document.querySelector(href);
                
                if (target) {
                    e.preventDefault();
                    
                    const headerOffset = 80;
                    const elementPosition = target.getBoundingClientRect().top;
                    const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
                    
                    window.scrollTo({
                        top: offsetPosition,
                        behavior: 'smooth'
                    });
                }
            }
        });
    });
}

/**
 * Scroll Effects
 */
function initScrollEffects() {
    const navbar = document.querySelector('.navbar');
    
    if (navbar) {
        let lastScroll = 0;
        
        window.addEventListener('scroll', function() {
            const currentScroll = window.pageYOffset;
            
            // Add shadow on scroll
            if (currentScroll > 10) {
                navbar.style.boxShadow = '0 4px 16px rgba(0, 0, 0, 0.12)';
            } else {
                navbar.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.08)';
            }
            
            lastScroll = currentScroll;
        });
    }
    
    // Animate elements on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);
    
    // Observe cards and sections
    const animateElements = document.querySelectorAll('.zone-card, .feature-card, .value-card, .requirement-card');
    animateElements.forEach((el, index) => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(22px) scale(0.98)';
        el.style.transition = `opacity 0.55s ease ${Math.min(index * 40, 220)}ms, transform 0.55s ease ${Math.min(index * 40, 220)}ms`;
        observer.observe(el);
    });
}

// Add CSS class for animated elements
document.head.insertAdjacentHTML('beforeend', `
    <style>
        .animate-in {
            opacity: 1 !important;
            transform: translateY(0) !important;
        }
    </style>
`);

/**
 * Utility: Debounce function
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Keyboard Navigation
 */
function initKeyboardNav() {
    // Skip to main content link
    const skipLink = document.createElement('a');
    const mainContent = document.getElementById('main-content') || document.querySelector('main') || document.querySelector('section');
    if (mainContent && !mainContent.id) {
        mainContent.id = 'main-content';
    }
    skipLink.href = '#main-content';
    skipLink.className = 'skip-to-main';
    skipLink.textContent = 'Skip to main content';
    skipLink.style.cssText = `
        position: absolute;
        top: -40px;
        left: 0;
        background: #6C63FF;
        color: white;
        padding: 8px;
        text-decoration: none;
        z-index: 100;
    `;
    skipLink.addEventListener('focus', () => {
        skipLink.style.top = '0';
    });
    skipLink.addEventListener('blur', () => {
        skipLink.style.top = '-40px';
    });
    document.body.insertBefore(skipLink, document.body.firstChild);

    // Keyboard support for buttons
    const buttons = document.querySelectorAll('[role="button"], .btn');
    buttons.forEach(button => {
        button.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                this.click();
            }
        });
    });
}

/**
 * Subtle visual polish without overwhelming motion.
 */
function initAmbientPolish() {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return;
    }

    // Slight parallax movement for floating emoji elements.
    const floaters = document.querySelectorAll('.floating-element');
    if (floaters.length > 0) {
        window.addEventListener('mousemove', debounce((event) => {
            const x = (event.clientX / window.innerWidth) - 0.5;
            const y = (event.clientY / window.innerHeight) - 0.5;

            floaters.forEach((el, i) => {
                const depth = (i + 1) * 2;
                el.style.transform = `translate(${x * depth}px, ${y * depth}px)`;
            });
        }, 16));
    }

    // Footer year auto-sync when relevant text exists.
    const footerText = document.querySelector('.footer-bottom p');
    if (footerText) {
        footerText.innerHTML = footerText.innerHTML.replace(/\b20\d{2}\b/, String(new Date().getFullYear()));
    }

    // Add smooth number counting for stats
    initCounters();

    // Initialize tooltip support
    initTooltips();
}

/**
 * Animated counters for stats
 */
function initCounters() {
    const counters = document.querySelectorAll('[data-count]');
    
    counters.forEach(counter => {
        const targetValue = parseFloat(counter.dataset.count);
        const suffix = counter.dataset.suffix || '';
        const duration = parseFloat(counter.dataset.duration) || 2000;
        
        const observerOptions = {
            threshold: 0.5
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    animateCounter(counter, 0, targetValue, duration, suffix);
                    observer.unobserve(entry.target);
                }
            });
        }, observerOptions);
        
        observer.observe(counter);
    });
}

function animateCounter(el, from, to, duration, suffix) {
    const startTime = performance.now();
    
    function update(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const easeOutValue = 1 - Math.pow(1 - progress, 3); // Ease-out cubic
        
        const currentValue = Math.floor(from + (to - from) * easeOutValue);
        el.textContent = currentValue + suffix;
        
        if (progress < 1) {
            requestAnimationFrame(update);
        }
    }
    
    requestAnimationFrame(update);
}

/**
 * Tooltip support with keyboard accessibility
 */
function initTooltips() {
    const tooltips = document.querySelectorAll('[data-tooltip]');
    
    tooltips.forEach(el => {
        const tooltip = document.createElement('div');
        tooltip.className = 'tooltip';
        tooltip.textContent = el.dataset.tooltip;
        tooltip.style.cssText = `
            position: absolute;
            background: #102a43;
            color: white;
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 0.875rem;
            white-space: nowrap;
            pointer-events: none;
            z-index: 1000;
            opacity: 0;
            transition: opacity 0.2s ease;
        `;
        
        document.body.appendChild(tooltip);
        
        function showTooltip() {
            const rect = el.getBoundingClientRect();
            tooltip.style.left = (rect.left + rect.width / 2 - tooltip.offsetWidth / 2) + window.pageXOffset + 'px';
            tooltip.style.top = (rect.top - tooltip.offsetHeight - 8) + window.pageYOffset + 'px';
            tooltip.style.opacity = '1';
        }
        
        function hideTooltip() {
            tooltip.style.opacity = '0';
        }
        
        el.addEventListener('mouseenter', showTooltip);
        el.addEventListener('mouseleave', hideTooltip);
        el.addEventListener('focus', showTooltip);
        el.addEventListener('blur', hideTooltip);
    });
}

/**
 * Form submission with validation
 */
function initFormHandling() {
    const forms = document.querySelectorAll('form[data-form-type]');
    
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formType = this.dataset.formType;
            const inputs = this.querySelectorAll('input, textarea');
            const isValid = validateForm(inputs);
            
            if (!isValid) return;
            
            if (formType === 'newsletter') {
                handleNewsletterSignup(this, inputs);
            } else if (formType === 'contact') {
                handleContactForm(this, inputs);
            }
        });
    });
}

function validateForm(inputs) {
    let isValid = true;
    
    inputs.forEach(input => {
        const value = input.value.trim();
        const error = input.parentElement.querySelector('.error-message');
        
        if (!value) {
            showError(input, 'This field is required');
            isValid = false;
        } else if (input.type === 'email' && !isValidEmail(value)) {
            showError(input, 'Please enter a valid email');
            isValid = false;
        } else {
            clearError(input);
        }
    });
    
    return isValid;
}

function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function showError(input, message) {
    let error = input.parentElement.querySelector('.error-message');
    if (!error) {
        error = document.createElement('span');
        error.className = 'error-message';
        error.style.cssText = `
            display: block;
            color: #dc2626;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        `;
        input.parentElement.appendChild(error);
    }
    error.textContent = message;
    input.style.borderColor = '#dc2626';
}

function clearError(input) {
    const error = input.parentElement.querySelector('.error-message');
    if (error) error.remove();
    input.style.borderColor = '';
}

function handleNewsletterSignup(form, inputs) {
    const emailInput = form.querySelector('input[type="email"]');
    const email = emailInput.value.trim();
    
    // Store in localStorage as demo
    localStorage.setItem('newsletter_email', email);
    
    showSuccessMessage(form, 'Thanks for signing up! Check your email for a welcome message.');
    form.reset();
}

function handleContactForm(form, inputs) {
    // In a real app, this would send to a backend
    const name = form.querySelector('input[name="name"]')?.value;
    const email = form.querySelector('input[name="email"]')?.value;
    
    localStorage.setItem('contact_form_' + Date.now(), JSON.stringify({
        name, email, timestamp: new Date().toISOString()
    }));
    
    showSuccessMessage(form, 'Thank you for reaching out! We will get back to you soon.');
    form.reset();
}

function showSuccessMessage(form, message) {
    let success = form.querySelector('.success-message');
    if (!success) {
        success = document.createElement('div');
        success.className = 'success-message';
        success.style.cssText = `
            background: #dcfce7;
            border: 1px solid #86efac;
            color: #166534;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        `;
        form.insertBefore(success, form.firstChild);
    }
    success.innerHTML = '✓ ' + message;
    success.style.display = 'block';
    
    setTimeout(() => {
        success.style.display = 'none';
    }, 4000);
}

/* ===================================
   Phase 1: Visual Polish Enhancements
   =================================== */

/**
 * Dark Mode Toggle
 */
function initDarkMode() {
    // Check for saved dark mode preference  
    const isDarkMode = localStorage.getItem('darkMode') === 'true' ||
                       window.matchMedia('(prefers-color-scheme: dark)').matches;
    
    if (isDarkMode) {
        document.documentElement.style.colorScheme = 'dark';
    }
    
    // Create toggle button
    const toggleBtn = document.createElement('button');
    toggleBtn.className = 'dark-mode-toggle';
    toggleBtn.setAttribute('aria-label', 'Toggle dark mode');
    toggleBtn.innerHTML = isDarkMode ? '☀️' : '🌙';
    document.body.appendChild(toggleBtn);
    
    toggleBtn.addEventListener('click', function() {
        const isDark = document.documentElement.style.colorScheme === 'dark';
        document.documentElement.style.colorScheme = isDark ? 'light' : 'dark';
        localStorage.setItem('darkMode', !isDark);
        this.innerHTML = isDark ? '🌙' : '☀️';
        this.style.animation = 'fadeInScale 0.4s ease';
    });
    
    // Listen for system color scheme changes
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
        if (localStorage.getItem('darkMode') !== 'true' && localStorage.getItem('darkMode') !== 'false') {
            document.documentElement.style.colorScheme = e.matches ? 'dark' : 'light';
            toggleBtn.innerHTML = e.matches ? '☀️' : '🌙';
        }
    });
}

/**
 * Enhanced Animations on Scroll
 */
function initEnhancedAnimations() {
    // Stagger animations for multiple cards
    const cardGroups = document.querySelectorAll('.stagger-in');
    
    cardGroups.forEach(group => {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const cards = entry.target.querySelectorAll('[class*="card"], [class*="item"]');
                    cards.forEach((card, index) => {
                        card.style.animation = `slideInUp 0.6s ease-out`;
                        card.style.animationDelay = `${index * 0.1}s`;
                        card.style.animationFillMode = 'both';
                    });
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.1 });
        
        observer.observe(group);
    });

    // Gentle bounce animation for CTAs
    const ctaButtons = document.querySelectorAll('.btn-primary');
    ctaButtons.forEach(btn => {
        btn.addEventListener('mouseenter', function() {
            if (window.matchMedia('(prefers-reduced-motion: no-preference)').matches) {
                this.style.animation = 'gentleBounce 0.6s ease';
            }
        });
    });
}

/**
 * Advanced Form Validation with Real-time Feedback
 */
function initFormValidation() {
    const forms = document.querySelectorAll('form[data-form-type]');
    
    forms.forEach(form => {
        const inputs = form.querySelectorAll('input, textarea');
        
        inputs.forEach(input => {
            input.addEventListener('blur', function() {
                validateInput(this);
            });
            
            input.addEventListener('input', function() {
                if (this.classList.contains('invalid')) {
                    validateInput(this);
                }
            });
        });
    });
}

function validateInput(input) {
    const value = input.value.trim();
    let isValid = true;
    let errorMsg = '';
    
    // Email validation
    if (input.type === 'email' && value) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        isValid = emailRegex.test(value);
        errorMsg = 'Please enter a valid email address';
    }
    
    // Required field validation
    if (input.hasAttribute('required') && !value) {
        isValid = false;
        errorMsg = 'This field is required';
    }
    
    // Min length validation
    const minLength = input.getAttribute('data-min-length');
    if (minLength && value.length < parseInt(minLength)) {
        isValid = false;
        errorMsg = `Minimum ${minLength} characters required`;
    }
    
    // Update UI
    if (!isValid) {
        input.classList.add('invalid');
        let error = input.parentElement.querySelector('.error-message');
        if (!error) {
            error = document.createElement('div');
            error.className = 'error-message';
            input.parentElement.appendChild(error);
        }
        error.textContent = errorMsg;
        error.style.display = 'block';
    } else {
        input.classList.remove('invalid');
        const error = input.parentElement.querySelector('.error-message');
        if (error) {
            error.style.display = 'none';
        }
    }
    
    return isValid;
}

/* ===================================
   Phase 2: Interactive Features
   =================================== */

/**
 * Modal Management
 */
function initModals() {
    const modals = document.querySelectorAll('.modal-overlay');
    
    // Setup close buttons
    modals.forEach(modal => {
        const closeBtn = modal.querySelector('.modal-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', () => closeModal(modal));
        }
        
        // Close on overlay click
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                closeModal(modal);
            }
        });
        
        // Close on Escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && modal.classList.contains('active')) {
                closeModal(modal);
            }
        });
    });
}

function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

function closeModal(modal) {
    modal.classList.remove('active');
    document.body.style.overflow = 'auto';
}

/**
 * Carousel/Slider Functionality
 */
function initCarousel() {
    const carousels = document.querySelectorAll('.carousel');
    
    carousels.forEach(carousel => {
        const inner = carousel.querySelector('.carousel-inner');
        const slides = carousel.querySelectorAll('.carousel-slide');
        const dots = carousel.querySelectorAll('.carousel-dot');
        const prevBtn = carousel.querySelector('.carousel-nav.prev');
        const nextBtn = carousel.querySelector('.carousel-nav.next');
        
        let currentSlide = 0;
        
        function showSlide(n) {
            if (n >= slides.length) currentSlide = 0;
            if (n < 0) currentSlide = slides.length - 1;
            
            inner.style.transform = `translateX(-${currentSlide * 100}%)`;
            
            dots.forEach((dot, index) => {
                dot.classList.toggle('active', index === currentSlide);
            });
        }
        
        if (nextBtn) {
            nextBtn.addEventListener('click', () => {
                currentSlide++;
                showSlide(currentSlide);
            });
        }
        
        if (prevBtn) {
            prevBtn.addEventListener('click', () => {
                currentSlide--;
                showSlide(currentSlide);
            });
        }
        
        dots.forEach((dot, index) => {
            dot.addEventListener('click', () => {
                currentSlide = index;
                showSlide(currentSlide);
            });
        });
        
        // Auto-advance slides every 5 seconds
        if (slides.length > 1) {
            setInterval(() => {
                currentSlide++;
                showSlide(currentSlide);
            }, 5000);
        }
    });
}

/**
 * Parallax Scroll Effect
 */
function initParallaxScroll() {
    const parallaxElements = document.querySelectorAll('.parallax-element');
    
    if (window.matchMedia('(prefers-reduced-motion: no-preference)').matches) {
        window.addEventListener('scroll', debounce(() => {
            parallaxElements.forEach(el => {
                const scrollPosition = window.pageYOffset;
                const elementPosition = el.getBoundingClientRect().top;
                const offset = scrollPosition - (elementPosition + window.innerHeight / 2);
                
                if (Math.abs(offset) < window.innerHeight) {
                    el.style.transform = `translateY(${offset * 0.5}px)`;
                }
            });
        }, 16));
    }
}

/**
 * Lazy Loading Images
 */
function initLazyLoading() {
    const lazyImages = document.querySelectorAll('img[data-src]');
    
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.classList.remove('lazy-image');
                    imageObserver.unobserve(img);
                }
            });
        }, { rootMargin: '50px' });
        
        lazyImages.forEach(img => {
            img.classList.add('lazy-image', 'loading');
            imageObserver.observe(img);
        });
    } else {
        // Fallback for browsers without IntersectionObserver
        lazyImages.forEach(img => {
            img.src = img.dataset.src;
        });
    }
}

/**
 * Page Progress Indicator
 */
function initProgressIndicator() {
    const progressBar = document.querySelector('.progress-container');
    if (!progressBar) return;
    
    window.addEventListener('scroll', debounce(() => {
        const scrollTop = window.scrollY;
        const docHeight = document.documentElement.scrollHeight - window.innerHeight;
        const scrollPercent = (scrollTop / docHeight) * 100;
        progressBar.style.width = scrollPercent + '%';
    }, 16));
}

/**
 * Toast Notification System
 */
function showToast(message, type = 'info', duration = 3000) {
    let container = document.querySelector('.toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }
    
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <div class="toast-content">
            <strong>${message}</strong>
        </div>
        <button class="toast-close">×</button>
    `;
    
    container.appendChild(toast);
    
    const closeBtn = toast.querySelector('.toast-close');
    closeBtn.addEventListener('click', () => {
        toast.remove();
    });
    
    setTimeout(() => {
        toast.remove();
    }, duration);
}

