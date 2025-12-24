// DOM Elements
// const startBtn = document.getElementById('start-btn'); // Removed as per request
const themeToggle = document.getElementById('theme-toggle');
const giftBox = document.getElementById('gift-container');
const popupOverlay = document.getElementById('popup-overlay');
const closePopup = document.getElementById('close-popup');
const currentDateEl = document.getElementById('current-date');

// Canvas Elements
const starCanvas = document.getElementById('star-map');
const trailCanvas = document.getElementById('mouse-trail');
const particleCanvas = document.getElementById('text-particles');
const gardenCanvas = document.getElementById('flower-garden');
const visualizerCanvas = document.getElementById('audio-visualizer');

// 1. Footer Date
const date = new Date();
currentDateEl.innerText = date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });

// 2. Music System (Revamped)
class MusicController {
    constructor() {
        // PRIORITY 1: Local file (Best for custom songs) -> Place 'music.mp3' in 'assets/' folder.
        // PRIORITY 2: Fallback URL (Upbeat Piano)

        // Uncomment this line if you have a local file:
        this.audio = new Audio('assets/music.mp3');

        // Current Fallback: "Sunny" - Bensound (Royalty Free style placeholder)
        // this.audio = new Audio('https://www.bensound.com/bensound-music/bensound-sunny.mp3');

        this.audio.loop = true;
        this.audio.volume = 0.5;
        this.isPlaying = false;

        // UI Elements
        this.toggleBtn = document.getElementById('music-toggle-btn');
        this.volumeSlider = document.getElementById('volume-slider');
        this.icon = this.toggleBtn.querySelector('i');

        // Entry Screen
        this.entryOverlay = document.getElementById('entry-overlay');
        this.enterBtn = document.getElementById('enter-btn');

        this.init();
    }

    init() {
        // Entry Point
        this.enterBtn.addEventListener('click', () => this.startExperience());

        // Controls
        this.toggleBtn.addEventListener('click', () => this.togglePlay());
        this.volumeSlider.addEventListener('input', (e) => this.setVolume(e.target.value));
    }

    startExperience() {
        // Fade out overlay
        this.entryOverlay.classList.add('hidden-fade');
        setTimeout(() => this.entryOverlay.remove(), 1000); // Cleanup DOM

        // Start Music
        this.playMusic();

        // Start Balloons
        startBalloons();
    }

    playMusic() {
        this.audio.play().then(() => {
            this.isPlaying = true;
            this.updateIcon();
        }).catch(e => {
            console.error("Music playback failed:", e);
            // Fallback: User might need to click play manually if browser blocked it despite interaction
        });
    }

    pauseMusic() {
        this.audio.pause();
        this.isPlaying = false;
        this.updateIcon();
    }

    togglePlay() {
        this.isPlaying ? this.pauseMusic() : this.playMusic();
    }

    setVolume(val) {
        this.audio.volume = val;
    }

    updateIcon() {
        if (this.isPlaying) {
            this.icon.classList.remove('fa-play');
            this.icon.classList.add('fa-pause');
        } else {
            this.icon.classList.remove('fa-pause');
            this.icon.classList.add('fa-play');
        }
    }
}

// Balloons Logic
function startBalloons() {
    const container = document.getElementById('balloon-container');
    if (!container) return;

    const colors = ['#FF69B4', '#FFB7C5', '#DDA0DD', '#87CEEB', '#FFD700'];

    setInterval(() => {
        const balloon = document.createElement('div');
        balloon.classList.add('balloon');

        // Random Properties
        const bg = colors[Math.floor(Math.random() * colors.length)];
        const left = Math.random() * 95; // 0 to 95%
        const duration = Math.random() * 5 + 5; // 5s to 10s

        balloon.style.backgroundColor = bg;
        balloon.style.left = left + 'vw';
        balloon.style.animationDuration = duration + 's';

        // Interaction
        balloon.addEventListener('click', (event) => {
            // Pop effect
            balloon.style.transform = 'scale(1.5)';
            balloon.style.opacity = '0';
            setTimeout(() => balloon.remove(), 200);

            // Confetti burst
            confetti({
                particleCount: 20,
                spread: 30,
                origin: { x: event.clientX / window.innerWidth, y: event.clientY / window.innerHeight }
            });
        });

        // Cleanup
        balloon.addEventListener('animationend', () => {
            balloon.remove();
        });

        container.appendChild(balloon);

    }, 1500); // Spawn every 1.5 seconds
}

// Initialize Music System
new MusicController();

// 3. Theme Toggle
themeToggle.addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    const themeIcon = themeToggle.querySelector('i');
    themeIcon.className = newTheme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
});

// 4. Scroll Observer
const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (entry.isIntersecting) entry.target.classList.add('visible');
    });
}, { threshold: 0.1 });
document.querySelectorAll('.fade-in-up, .section-title, .reveal-text').forEach(el => {
    el.classList.add('fade-in-up');
    observer.observe(el);
});

// 5. Star Map (Canvas)
const starCtx = starCanvas.getContext('2d');
let stars = [];
function resizeStars() { starCanvas.width = window.innerWidth; starCanvas.height = window.innerHeight; initStars(); }
window.addEventListener('resize', resizeStars);

class Star {
    constructor() {
        this.x = Math.random() * starCanvas.width;
        this.y = Math.random() * starCanvas.height;
        this.size = Math.random() * 2;
        this.speedX = Math.random() * 0.5 - 0.25;
        this.speedY = Math.random() * 0.5 - 0.25;
    }
    update() {
        this.x += this.speedX;
        this.y += this.speedY;
        if (this.x < 0) this.x = starCanvas.width;
        if (this.x > starCanvas.width) this.x = 0;
        if (this.y < 0) this.y = starCanvas.height;
        if (this.y > starCanvas.height) this.y = 0;
    }
    draw() {
        starCtx.fillStyle = document.documentElement.getAttribute('data-theme') === 'dark' ? 'white' : '#FF69B4';
        starCtx.beginPath();
        starCtx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        starCtx.fill();
    }
}
function initStars() {
    stars = [];
    for (let i = 0; i < 100; i++) stars.push(new Star());
}
function animateStars() {
    starCtx.clearRect(0, 0, starCanvas.width, starCanvas.height);
    stars.forEach(star => {
        star.update();
        star.draw();
        // Connect near mouse
        const dx = mouse.x - star.x;
        const dy = mouse.y - star.y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < 100) {
            starCtx.strokeStyle = 'rgba(255, 105, 180, 0.2)';
            starCtx.lineWidth = 1;
            starCtx.beginPath();
            starCtx.moveTo(star.x, star.y);
            starCtx.lineTo(mouse.x, mouse.y);
            starCtx.stroke();
        }
    });
    requestAnimationFrame(animateStars);
}

// 6. Magic Mouse Trail
const trailCtx = trailCanvas.getContext('2d');
let trailParticles = [];
const mouse = { x: undefined, y: undefined };
window.addEventListener('mousemove', e => {
    mouse.x = e.x;
    mouse.y = e.y;
    for (let i = 0; i < 3; i++) {
        trailParticles.push(new Particle());
    }
});
function resizeTrail() { trailCanvas.width = window.innerWidth; trailCanvas.height = window.innerHeight; }
window.addEventListener('resize', resizeTrail);

class Particle {
    constructor() {
        this.x = mouse.x;
        this.y = mouse.y;
        this.size = Math.random() * 5 + 1;
        this.speedX = Math.random() * 3 - 1.5;
        this.speedY = Math.random() * 3 - 1.5;
        this.color = `hsl(${Math.random() * 360}, 100%, 50%)`;
    }
    update() {
        this.x += this.speedX;
        this.y += this.speedY;
        if (this.size > 0.2) this.size -= 0.1;
    }
    draw() {
        trailCtx.fillStyle = this.color;
        trailCtx.beginPath();
        trailCtx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        trailCtx.fill();
    }
}
function handleTrail() {
    trailCtx.clearRect(0, 0, trailCanvas.width, trailCanvas.height);
    for (let i = 0; i < trailParticles.length; i++) {
        trailParticles[i].update();
        trailParticles[i].draw();
        if (trailParticles[i].size <= 0.2) {
            trailParticles.splice(i, 1);
            i--;
        }
    }
    requestAnimationFrame(handleTrail);
}

// 7. Particle Text Effect (Hero)
const pCtx = particleCanvas.getContext('2d');
let particleTextArray = [];
function initParticleText() {
    // Adjusted dimensions for new layout
    particleCanvas.width = 800;
    particleCanvas.height = 150;
    pCtx.fillStyle = '#FF69B4'; // Drawing color
    pCtx.font = 'bold 80px Playfair Display';
    pCtx.textAlign = 'center';
    pCtx.textBaseline = 'middle';

    // Draw text in center of canvas
    pCtx.fillText('Shraddha', particleCanvas.width / 2, particleCanvas.height / 2);

    const textCoordinates = pCtx.getImageData(0, 0, particleCanvas.width, particleCanvas.height);

    class TextParticle {
        constructor(x, y) {
            this.x = x; this.y = y;
            this.size = 2;
            this.baseX = x; this.baseY = y;
            this.density = (Math.random() * 30) + 1;
        }
        draw() {
            pCtx.fillStyle = 'pink';
            pCtx.beginPath();
            pCtx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            pCtx.closePath();
            pCtx.fill();
        }
        update() {
            let dx = mouse.x - this.x - particleCanvas.getBoundingClientRect().left;
            let dy = mouse.y - this.y - particleCanvas.getBoundingClientRect().top;
            let distance = Math.sqrt(dx * dx + dy * dy);
            let forceDirectionX = dx / distance;
            let forceDirectionY = dy / distance;
            let maxDistance = 100; // Interaction radius
            let force = (maxDistance - distance) / maxDistance;
            let directionX = forceDirectionX * force * this.density;
            let directionY = forceDirectionY * force * this.density;

            if (distance < maxDistance) {
                this.x -= directionX;
                this.y -= directionY;
            } else {
                if (this.x !== this.baseX) {
                    let dx = this.x - this.baseX;
                    this.x -= dx / 10;
                }
                if (this.y !== this.baseY) {
                    let dy = this.y - this.baseY;
                    this.y -= dy / 10;
                }
            }
        }
    }
    particleTextArray = [];
    for (let y = 0, y2 = textCoordinates.height; y < y2; y++) {
        for (let x = 0, x2 = textCoordinates.width; x < x2; x++) {
            // Check alpha value (approx > 128)
            if (textCoordinates.data[(y * 4 * textCoordinates.width) + (x * 4) + 3] > 128) {
                let positionX = x;
                let positionY = y;
                particleTextArray.push(new TextParticle(positionX, positionY));
            }
        }
    }
}
function animateTextParticles() {
    pCtx.clearRect(0, 0, particleCanvas.width, particleCanvas.height);
    particleTextArray.forEach(p => { p.draw(); p.update(); });
    requestAnimationFrame(animateTextParticles);
}

// 8. Interactive Cake
const flames = document.querySelectorAll('.flame');
const smokes = document.querySelectorAll('.smoke');
const wishMsg = document.getElementById('wish-message');

flames.forEach((flame, index) => {
    flame.addEventListener('click', () => {
        flame.classList.add('hidden');
        smokes[index].classList.remove('hidden');
        checkCandles();
    });
});
function checkCandles() {
    const activeFlames = document.querySelectorAll('.flame:not(.hidden)');
    if (activeFlames.length === 0) {
        setTimeout(() => wishMsg.classList.remove('hidden'), 500);
        confetti({
            particleCount: 100,
            spread: 70,
            origin: { y: 0.6 }
        });
    }
}

// 9. Open When Letters
window.openLetter = function (type) {
    const modal = document.getElementById('letter-modal');
    const title = document.getElementById('letter-title');
    const body = document.getElementById('letter-body');

    modal.classList.remove('hidden');
    setTimeout(() => modal.classList.add('show'), 10);

    const messages = {
        'sad': { t: 'When/If You Feel Sad', b: 'Remember that you are incredibly strong. This feeling will pass. I am always a phone call away. 🫂' },
        'happy': { t: 'Yay! You\'re Happy!', b: 'Keep shining! Your happiness is contagious. Go treat yourself to something nice! 🍦' },
        'bored': { t: 'Bored?', b: 'Did you know octopuses have 3 hearts? Now you do. Go text me, let\'s do something fun! 🐙' }
    };

    title.innerText = messages[type].t;
    body.innerText = messages[type].b;
}

window.closeLetter = function () {
    const modal = document.getElementById('letter-modal');
    modal.classList.remove('show');
    setTimeout(() => modal.classList.add('hidden'), 300);
}

// 10. Gift Box & Confetti Fix
giftBox.addEventListener('click', () => {
    const box = giftBox.querySelector('.gift-box');
    if (box.classList.contains('open')) return;
    box.classList.add('open');

    // Fire confetti for finite time
    let duration = 3000;
    let end = Date.now() + duration;

    (function frame() {
        confetti({
            particleCount: 5,
            angle: 60,
            spread: 55,
            origin: { x: 0 }
        });
        confetti({
            particleCount: 5,
            angle: 120,
            spread: 55,
            origin: { x: 1 }
        });

        if (Date.now() < end) {
            requestAnimationFrame(frame);
        }
    }());

    setTimeout(() => {
        popupOverlay.classList.remove('hidden');
        setTimeout(() => popupOverlay.classList.add('show'), 10);
    }, 1500);
});
closePopup.addEventListener('click', () => {
    popupOverlay.classList.remove('show');
    setTimeout(() => popupOverlay.classList.add('hidden'), 300);
});

// Flipbook Manual Click Logic
const book = document.querySelector('.book');
const pages = document.querySelectorAll('.page');

// Open book container on first interaction (optional, or just logic)
// We treat the first page click as "opening" logic
pages.forEach((page, index) => {
    page.addEventListener('click', (e) => {
        // Stop bubbling so we don't trigger parent clicks unnecessarily
        e.stopPropagation();

        if (index === 0) {
            // Clicking cover
            book.classList.add('book-open');
        }

        // Toggle Flip
        if (page.classList.contains('flipped')) {
            page.classList.remove('flipped');
            // Logic: if I unflip page 2, page 3 should probably unflip too?
            // For simple "book", usually you flip pages sequentially.
            // If I click a flipped page (back side), I want to go back.

            // Unflip all pages AFTER this one too?
            for (let i = index + 1; i < pages.length; i++) {
                pages[i].classList.remove('flipped');
            }

        } else {
            page.classList.add('flipped');
            // Ensure all pages BEFORE this one are flipped?
            for (let i = 0; i < index; i++) {
                pages[i].classList.add('flipped');
            }
        }
    });
});


// 11. Flower Garden (Footer)
const gardenCtx = gardenCanvas.getContext('2d');
function resizeGarden() { gardenCanvas.width = window.innerWidth; gardenCanvas.height = 200; }
window.addEventListener('resize', resizeGarden);

function drawFlower(x, y, petalColor) {
    gardenCtx.beginPath();
    gardenCtx.moveTo(x, y);
    gardenCtx.lineTo(x, y + 50); // Stem
    gardenCtx.strokeStyle = 'green';
    gardenCtx.stroke();

    gardenCtx.fillStyle = petalColor;
    for (let i = 0; i < 5; i++) {
        gardenCtx.beginPath();
        gardenCtx.arc(x + Math.sin(i) * 10, y + Math.cos(i) * 10, 5, 0, Math.PI * 2);
        gardenCtx.fill();
    }
    gardenCtx.beginPath();
    gardenCtx.arc(x, y, 3, 0, Math.PI * 2);
    gardenCtx.fillStyle = 'yellow';
    gardenCtx.fill();
}

let hasGrown = false;
window.addEventListener('scroll', () => {
    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight - 50) {
        if (!hasGrown) {
            hasGrown = true;
            for (let i = 0; i < window.innerWidth; i += 30) {
                setTimeout(() => {
                    const color = `hsl(${Math.random() * 360}, 70%, 70%)`;
                    drawFlower(i, 150, color);
                }, Math.random() * 1000);
            }
        }
    }
});

// Carousel Logic (Refined)
const track = document.querySelector('.carousel-track');
const slides = Array.from(track.children);
const nextButton = document.querySelector('.carousel-button--right');
const prevButton = document.querySelector('.carousel-button--left');
const dotsNav = document.querySelector('.carousel-nav');
const dots = Array.from(dotsNav.children);

const slideWidth = slides[0].getBoundingClientRect().width;
const setSlidePosition = (slide, index) => { slide.style.left = slideWidth * index + 'px'; };
slides.forEach(setSlidePosition);

const moveToSlide = (track, currentSlide, targetSlide) => {
    track.style.transform = 'translateX(-' + targetSlide.style.left + ')';
    currentSlide.classList.remove('current-slide');
    targetSlide.classList.add('current-slide');

    // Update dots
    const currentDot = dotsNav.querySelector('.current-slide');
    const targetIndex = slides.findIndex(slide => slide === targetSlide);
    const targetDot = dots[targetIndex];
    if (currentDot) currentDot.classList.remove('current-slide');
    if (targetDot) targetDot.classList.add('current-slide');
};

const nextSlide = () => {
    const currentSlide = track.querySelector('.current-slide');
    const nextSlide = currentSlide.nextElementSibling || slides[0];
    moveToSlide(track, currentSlide, nextSlide);
};

const prevSlide = () => {
    const currentSlide = track.querySelector('.current-slide');
    const prevSlide = currentSlide.previousElementSibling || slides[slides.length - 1];
    moveToSlide(track, currentSlide, prevSlide);
};

// Event Listeners for Buttons
nextButton.addEventListener('click', nextSlide);
prevButton.addEventListener('click', prevSlide);

// Keydown listeners (New Feature)
document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight') nextSlide();
    if (e.key === 'ArrowLeft') prevSlide();
});

// Auto slide
setInterval(nextSlide, 5000);


// Initialize loops
resizeStars();
initStars();
animateStars();
resizeTrail();
handleTrail();
setTimeout(() => {
    initParticleText();
    animateTextParticles();
}, 1000); // Wait for fonts to load
resizeGarden();

// ---------------------------------
// Phase 5: Countdown Logic
// ---------------------------------
const countdownOverlay = document.getElementById('countdown-overlay');
const daysEl = document.getElementById('days');
const hoursEl = document.getElementById('hours');
const minutesEl = document.getElementById('minutes');
const secondsEl = document.getElementById('seconds');

// Target Date: PAST (Unlock Immediately) - For Development
// const birthdayDate = new Date('December 28, 2024 00:00:00').getTime();
const birthdayDate = new Date('December 28, 2025 00:00:00').getTime();

// TEST MODE: 1 Minute from now
// const birthdayDate = new Date().getTime() + 60000;

function updateCountdown() {
    const now = new Date().getTime();
    const distance = birthdayDate - now;

    if (distance < 0) {
        // Birthday has arrived!
        clearInterval(countdownInterval);

        // Auto-hide overlay
        countdownOverlay.classList.add('hidden');
        document.body.style.overflow = 'auto';

        return;
    }

    // Time calculations
    const days = Math.floor(distance / (1000 * 60 * 60 * 24));
    const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((distance % (1000 * 60)) / 1000);

    // Display
    daysEl.innerText = days < 10 ? '0' + days : days;
    hoursEl.innerText = hours < 10 ? '0' + hours : hours;
    minutesEl.innerText = minutes < 10 ? '0' + minutes : minutes;
    secondsEl.innerText = seconds < 10 ? '0' + seconds : seconds;

    // Lock scroll while countdown is active
    document.body.style.overflow = 'hidden';
}

const countdownInterval = setInterval(updateCountdown, 1000);
updateCountdown(); // Initial call
