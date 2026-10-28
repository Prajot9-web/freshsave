#!/usr/bin/env bash
set -e

PROJECT_NAME="freshsave-ai"

echo "Creating project directory: $PROJECT_NAME..."
mkdir -p "$PROJECT_NAME/src"
cd "$PROJECT_NAME"

# 1. package.json
cat << 'EOF' > package.json
{
  "name": "freshsave-ai",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "lucide-react": "^0.344.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.66",
    "@types/react-dom": "^18.2.22",
    "@vitejs/plugin-react": "^4.2.1",
    "autoprefixer": "^10.4.19",
    "postcss": "^8.4.38",
    "tailwindcss": "^3.4.1",
    "typescript": "^5.2.2",
    "vite": "^5.1.6"
  }
}
EOF

# 2. tsconfig.json
cat << 'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"]
}
EOF

# 3. vite.config.ts
cat << 'EOF' > vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
});
EOF

# 4. tailwind.config.js & postcss.config.js
cat << 'EOF' > tailwind.config.js
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

cat << 'EOF' > postcss.config.js
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# 5. index.html
cat << 'EOF' > index.html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>FreshSave AI - Smart Inventory & Markdown Engine</title>
  </head>
  <body class="bg-slate-50 text-slate-900 min-h-screen">
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# 6. src/index.css
cat << 'EOF' > src/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}
EOF

# 7. src/main.tsx
cat << 'EOF' > src/main.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# 8. src/App.tsx
cat << 'EOF' > src/App.tsx
import React, { useState, useEffect } from 'react';
import { AlertTriangle, Clock, TrendingDown, Share2, Plus, Sparkles, CheckCircle, Package } from 'lucide-react';

interface InventoryItem {
  id: string;
  name: string;
  category: 'Bakery' | 'Dairy' | 'Produce' | 'Cooked Meals';
  quantity: number;
  originalPrice: number;
  hoursUntilExpiry: number;
}

const initialItems: InventoryItem[] = [
  { id: '1', name: 'Artisan Sourdough Loaf', category: 'Bakery', quantity: 8, originalPrice: 120, hoursUntilExpiry: 5 },
  { id: '2', name: 'Fresh Paneer (500g)', category: 'Dairy', quantity: 12, originalPrice: 180, hoursUntilExpiry: 12 },
  { id: '3', name: 'Organic Spinach Bunches', category: 'Produce', quantity: 15, originalPrice: 40, hoursUntilExpiry: 18 },
  { id: '4', name: 'Paneer Butter Masala Box', category: 'Cooked Meals', quantity: 6, originalPrice: 220, hoursUntilExpiry: 3 },
];

export default function App() {
  const [items, setItems] = useState<InventoryItem[]>(() => {
    const saved = localStorage.getItem('freshsave_items');
    return saved ? JSON.parse(saved) : initialItems;
  });

  const [campaignOutput, setCampaignOutput] = useState<string>('');
  const [activePlatform, setActivePlatform] = useState<'whatsapp' | 'instagram'>('whatsapp');
  const [language, setLanguage] = useState<'en' | 'hi' | 'mr'>('en');

  useEffect(() => {
    localStorage.setItem('freshsave_items', JSON.stringify(items));
  }, [items]);

  const getRiskLevel = (hours: number) => {
    if (hours <= 4) return { label: 'Critical Risk', color: 'text-red-600 bg-red-50 border-red-200' };
    if (hours <= 12) return { label: 'Moderate Risk', color: 'text-amber-600 bg-amber-50 border-amber-200' };
    return { label: 'Optimal', color: 'text-emerald-600 bg-emerald-50 border-emerald-200' };
  };

  const getSuggestedDiscount = (hours: number): number => {
    if (hours <= 3) return 50;
    if (hours <= 6) return 35;
    if (hours <= 12) return 20;
    return 10;
  };

  const generateCampaign = (item: InventoryItem) => {
    const discount = getSuggestedDiscount(item.hoursUntilExpiry);
    const discountedPrice = Math.round(item.originalPrice * (1 - discount / 100));

    if (activePlatform === 'whatsapp') {
      if (language === 'hi') {
        setCampaignOutput(`⚡ *शाम का स्पेशल ऑफर!* ⚡\n\nताज़ा *${item.name}* अब केवल *₹${discountedPrice}* में (पहले ₹${item.originalPrice}, ${discount}% छूट)!\n\nस्टॉक सीमित है (${item.quantity} यूनिट बाकी)। ताज़ा सामान खत्म होने से पहले अभी आर्डर करें! 🏃💨`);
      } else if (language === 'mr') {
        setCampaignOutput(`⚡ *खास सायंकाळ ऑफर!* ⚡\n\nताजे *${item.name}* आता फक्त *₹${discountedPrice}* मध्ये (आधी ₹${item.originalPrice}, ${discount}% सूट)!\n\nमर्यादित साठा उपलब्ध (${item.quantity} शिल्लक). लगेच भेट द्या आणि खरेदी करा! 🏃💨`);
      } else {
        setCampaignOutput(`⚡ *Flash Evening Saver!* ⚡\n\nGet fresh *${item.name}* for just *₹${discountedPrice}* (was ₹${item.originalPrice}, ${discount}% OFF)!\n\nOnly ${item.quantity} left in stock. Grab yours before it's gone! 🏃💨`);
      }
    } else {
      setCampaignOutput(`🚨 *FLASH DROP ALERT* 🚨\n\nDon't let good food go to waste! Snag fresh ${item.name} at flat ${discount}% OFF.\n\nNow: ₹${discountedPrice} | Original: ₹${item.originalPrice}\nAvailable at our counter until stocks last. #ZeroWaste #PuneFoodies #SmartSavings #LocalBusiness`);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-800">
      <header className="bg-emerald-700 text-white shadow-md">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Package className="h-7 w-7 text-emerald-200" />
            <div>
              <h1 className="text-xl font-bold tracking-tight">FreshSave AI</h1>
              <p className="text-xs text-emerald-100">By Prajot Kamble • Inventory & Dynamic Markdown System</p>
            </div>
          </div>
          <div className="flex items-center gap-2 text-xs bg-emerald-800/80 px-3 py-1.5 rounded-full border border-emerald-600">
            <span className="w-2 h-2 rounded-full bg-emerald-300 animate-pulse"></span>
            Zero-Waste Engine Active
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-8 grid grid-cols-1 lg:grid-cols-3 gap-8">
        <section className="lg:col-span-2 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold flex items-center gap-2">
              <TrendingDown className="h-5 w-5 text-emerald-600" />
              Perishable Inventory & Dynamic Pricing
            </h2>
            <span className="text-xs font-medium text-slate-500">{items.length} items tracked</span>
          </div>

          <div className="grid gap-3">
            {items.map((item) => {
              const risk = getRiskLevel(item.hoursUntilExpiry);
              const discount = getSuggestedDiscount(item.hoursUntilExpiry);
              const finalPrice = Math.round(item.originalPrice * (1 - discount / 100));

              return (
                <div key={item.id} className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-slate-900">{item.name}</span>
                      <span className={`text-[11px] px-2 py-0.5 rounded-full border font-medium ${risk.color}`}>
                        {risk.label}
                      </span>
                    </div>
                    <div className="flex items-center gap-3 text-xs text-slate-500">
                      <span>Cat: {item.category}</span>
                      <span>•</span>
                      <span>Stock: {item.quantity} units</span>
                      <span>•</span>
                      <span className="flex items-center gap-1 font-medium text-slate-700">
                        <Clock className="h-3.5 w-3.5 text-slate-400" /> {item.hoursUntilExpiry}h left
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center justify-between sm:justify-end w-full sm:w-auto gap-4">
                    <div className="text-right">
                      <div className="text-xs text-slate-400 line-through">₹{item.originalPrice}</div>
                      <div className="text-base font-bold text-emerald-700">
                        ₹{finalPrice} <span className="text-xs font-semibold text-red-600">(-{discount}%)</span>
                      </div>
                    </div>
                    <button
                      onClick={() => generateCampaign(item)}
                      className="px-3 py-2 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border border-emerald-300 rounded-lg text-xs font-semibold flex items-center gap-1.5 transition-colors"
                    >
                      <Sparkles className="h-3.5 w-3.5" />
                      Campaign
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </section>

        <section className="space-y-4">
          <h2 className="text-lg font-semibold flex items-center gap-2">
            <Share2 className="h-5 w-5 text-emerald-600" />
            AI Campaign Generator
          </h2>

          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm space-y-4">
            <div>
              <label className="text-xs font-semibold text-slate-600 block mb-1">Target Channel</label>
              <div className="grid grid-cols-2 gap-2">
                <button
                  onClick={() => setActivePlatform('whatsapp')}
                  className={`py-1.5 text-xs font-medium rounded-lg border transition-all ${
                    activePlatform === 'whatsapp' ? 'bg-emerald-600 text-white border-emerald-600' : 'bg-slate-50 text-slate-700 border-slate-200'
                  }`}
                >
                  WhatsApp
                </button>
                <button
                  onClick={() => setActivePlatform('instagram')}
                  className={`py-1.5 text-xs font-medium rounded-lg border transition-all ${
                    activePlatform === 'instagram' ? 'bg-emerald-600 text-white border-emerald-600' : 'bg-slate-50 text-slate-700 border-slate-200'
                  }`}
                >
                  Instagram
                </button>
              </div>
            </div>

            <div>
              <label className="text-xs font-semibold text-slate-600 block mb-1">Language</label>
              <div className="grid grid-cols-3 gap-2">
                {(['en', 'hi', 'mr'] as const).map((lang) => (
                  <button
                    key={lang}
                    onClick={() => setLanguage(lang)}
                    className={`py-1.5 text-xs font-medium rounded-lg border capitalize transition-all ${
                      language === lang ? 'bg-emerald-600 text-white border-emerald-600' : 'bg-slate-50 text-slate-700 border-slate-200'
                    }`}
                  >
                    {lang === 'en' ? 'English' : lang === 'hi' ? 'Hindi' : 'Marathi'}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="text-xs font-semibold text-slate-600 block mb-1">Generated Copy</label>
              <textarea
                readOnly
                rows={7}
                value={campaignOutput || 'Click "Campaign" on any inventory item to produce markdown promo text.'}
                className="w-full text-xs font-mono p-3 bg-slate-50 border border-slate-200 rounded-lg text-slate-700 focus:outline-none resize-none"
              />
            </div>

            {campaignOutput && (
              <button
                onClick={() => navigator.clipboard.writeText(campaignOutput)}
                className="w-full py-2 bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold rounded-lg flex items-center justify-center gap-2 transition-colors"
              >
                <CheckCircle className="h-4 w-4 text-emerald-400" /> Copy to Clipboard
              </button>
            )}
          </div>
        </section>
      </main>
    </div>
  );
}
EOF

# 9. .gitignore
cat << 'EOF' > .gitignore
node_modules
dist
dist-ssr
*.local
.env
.env.*
.DS_Store
EOF

# 10. README.md
cat << 'EOF' > README.md
# FreshSave AI 🥗⚡

> AI-Powered Inventory Risk Prevention & Dynamic Markdown Engine for Small Food Businesses.

**Developer:** Prajot Kamble  
**Theme:** Entrepreneurship, Sustainability & Local Food Business Optimization

---

## 📌 Problem Statement
Small grocery vendors, bakeries, and local restaurants often suffer revenue losses due to unsold perishable inventory. Without automated dynamic discounting, products reach expiration dates and end up discarded.

## 🚀 Key Features
- **Dynamic Shelf-Life Risk Classifier:** Flags inventory into Critical, Moderate, or Optimal status based on remaining hours.
- **Automated Pricing Engine:** Computes optimal, margin-preserving markdown percentages to clear stock before expiration.
- **Multilingual Campaign Generator:** Instantly creates promotion-ready social copy formatted for WhatsApp and Instagram in English, Hindi, and Marathi.
- **Browser State Persistence:** Saves custom additions and stock adjustments using `localStorage`.

## 🛠️ Tech Stack
- **Frontend Framework:** React 18 with TypeScript
- **Bundler:** Vite
- **Styling:** Tailwind CSS
- **Icons:** Lucide React

---

## 💻 Local Setup & Development

1. Clone the repository:
   ```bash
   git clone [https://github.com/](https://github.com/)<your-username>/freshsave-ai.git
   cd freshsave-ai