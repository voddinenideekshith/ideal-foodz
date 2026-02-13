// Simple cart implementation and WhatsApp checkout
(function(){
  const WA_BASE = 'https://wa.me/918985562963';

  const qs = sel => document.querySelector(sel);
  const qsa = sel => Array.from(document.querySelectorAll(sel));

  let cart = JSON.parse(localStorage.getItem('ideal_cart')||'{}');

  function save(){ localStorage.setItem('ideal_cart', JSON.stringify(cart)); updateUI(); }

  function addItem(name, price){
    if(!cart[name]) cart[name] = {price: +price, qty:0};
    cart[name].qty++;
    save();
  }

  function removeItem(name){ delete cart[name]; save(); }

  function changeQty(name, delta){ if(!cart[name]) return; cart[name].qty += delta; if(cart[name].qty<=0) removeItem(name); save(); }

  function clearCart(){ cart={}; save(); }

  function getTotal(){ return Object.keys(cart).reduce((s,k)=> s + cart[k].price*cart[k].qty, 0); }

  function updateUI(){
    const cartEl = qs('#cart');
    cartEl.innerHTML = '';
    const entries = Object.entries(cart);
    if(entries.length===0){ cartEl.innerHTML = '<p class="muted">Your cart is empty. Add items to get started.</p>'; }
    else{
      entries.forEach(([name, it])=>{
        const row = document.createElement('div'); row.className='cart-item';
        row.innerHTML = `<div><strong>${name}</strong><div class="muted">₹${it.price} each</div></div>
          <div class="qty-controls">
            <button class="qty-btn" data-action="dec" data-name="${name}">-</button>
            <div>${it.qty}</div>
            <button class="qty-btn" data-action="inc" data-name="${name}">+</button>
            <div style="min-width:60px;text-align:right;font-weight:700">₹${it.price*it.qty}</div>
          </div>`;
        cartEl.appendChild(row);
      });
    }
    qs('#total').textContent = `₹${getTotal()}`;
    qs('#sticky-count').textContent = entries.reduce((s,[,it])=> s+it.qty,0);
  }

  // event binding for add buttons
  document.addEventListener('click', e=>{
    const add = e.target.closest('.add-btn');
    if(add){
      const card = add.closest('.card');
      const name = card.dataset.name;
      const price = card.dataset.price;
      addItem(name, price);
      // small animation
      add.animate([{transform:'scale(1.05)'},{transform:'scale(1)'}],{duration:220});
      return;
    }

    const qbtn = e.target.closest('.qty-btn');
    if(qbtn){
      const name = qbtn.dataset.name;
      if(qbtn.dataset.action==='inc') changeQty(name, 1);
      else changeQty(name, -1);
      return;
    }

    if(e.target.id==='clear-cart'){ clearCart(); }
    if(e.target.id==='checkout'){
      const entries = Object.entries(cart);
      if(entries.length===0){ alert('Please add items to the cart first.'); return; }
      const lines = entries.map(([n,it])=> `${it.qty} x ${n} (₹${it.price*it.qty})`);
      lines.push(`Total: ₹${getTotal()}`);
      const msg = `Hi Ideal Foodz, I would like to order: ${lines.join(', ')}`;
      const url = WA_BASE + '?text=' + encodeURIComponent(msg);
      window.open(url,'_blank');
    }
  });

  // sticky order button scrolls to cart
  qs('#sticky-order').addEventListener('click', ()=>{
    document.querySelector('#order').scrollIntoView({behavior:'smooth', block:'start'});
  });

  // smooth scroll for nav links
  qsa('a[href^="#"]').forEach(a=>{
    a.addEventListener('click', e=>{
      const href = a.getAttribute('href');
      if(href.startsWith('#')){
        e.preventDefault();
        const el = document.querySelector(href);
        if(el) el.scrollIntoView({behavior:'smooth', block:'start'});
      }
    });
  });

  // init add button listeners assigned via event delegation above
  // expose simple admin-editable menu structure (for later CMS integration)
  window.IDEAL_FOODZ_ADMIN = {
    addItemToMenu(name, price){ /* implement server sync here */ }
  };

  // start
  document.addEventListener('DOMContentLoaded', ()=>{
    updateUI();
  });
})();
