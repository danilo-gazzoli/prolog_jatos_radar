class Boom{
    constructor(x, y, angle, jetSize, size=3, speed=4){
        this.x = x - Math.sin(angle)*(jetSize/2);
        this.y = y - Math.cos(angle)*(jetSize/2);
        this.angle = angle;
        this.size = size;
        this.speed = speed;
        this.deactivated = false;
        this.opacity = 1.0;
        this.arena = null;
        this.worldWidth = 0;
        this.worldHeight = 0;
        this.rad=Math.hypot(this.size,this.size)/2;
        this.alpha=Math.atan2(this.size,this.size);
        this.circle = [{x:0,y:0},{x:0,y:0},{x:0,y:0},{x:0,y:0}];
    }

    deactivate() {
        this.deactivated = true;
        this.opacity = 0;
    }

    getCircle() {
        if (this.deactivated) return [];
        else return this.circle;
    }

    #move(){
        this.x-=Math.sin(this.angle)*this.speed;
        this.y-=Math.cos(this.angle)*this.speed;
    }

    #wrapPosition() {
        if (!this.arena) return;

        this.worldWidth  = this.arena.right  - this.arena.left;
        this.worldHeight = this.arena.bottom - this.arena.top;

        if (this.x > this.arena.right) //  Direita -> esquerda
            this.x -= this.worldWidth;
        else
        if (this.x < this.arena.left) // Esquerda -> direita
            this.x += this.worldWidth;

        if (this.y > this.arena.bottom) // Baixo -> cima
            this.y -= this.worldHeight;
        else
        if (this.y < this.arena.top) // Cima -> baixo
            this.y += this.worldHeight;
    }

    update(arena) {
        if (this.deactivated) return;
        this.arena = arena;
        this.worldWidth=arena.right-arena.left;
        this.worldHeight=arena.bottom-arena.top;
        this.#move();
        this.#wrapPosition();
        this.#updateCircle();
        // perde a opacidade devagar até 0.87, depois, desaparece rápido
        this.opacity -= (this.opacity>0.87)?0.001:0.1;
        if (this.opacity <= 0) this.deactivate();
    }

    #updateCircle(){
        const a=this.angle,r=this.rad,al=this.alpha;
        this.circle[0].x=this.x-Math.sin(a-al)*r;
        this.circle[0].y=this.y-Math.cos(a-al)*r;
        this.circle[1].x=this.x-Math.sin(a+al)*r;
        this.circle[1].y=this.y-Math.cos(a+al)*r;
        this.circle[2].x=this.x-Math.sin(Math.PI+a-al)*r;
        this.circle[2].y=this.y-Math.cos(Math.PI+a-al)*r;
        this.circle[3].x=this.x-Math.sin(Math.PI+a+al)*r;
        this.circle[3].y=this.y-Math.cos(Math.PI+a+al)*r;
    }

    draw(ctx) {
        if (this.deactivated || !this.arena) return;

        const halfSize = this.size * 2;

        this.#drawAt(ctx, this.x, this.y);

        // Próximo da esquerda.
        if (this.x - halfSize < this.arena.left)
            this.#drawAt(ctx, this.x + this.worldWidth, this.y);

        // Próximo da direita.
        if (this.x + halfSize > this.arena.right)
            this.#drawAt(ctx, this.x - this.worldWidth, this.y);

        // Próximo do topo.
        if (this.y - halfSize < this.arena.top)
            this.#drawAt(ctx, this.x, this.y + this.worldHeight);

        // Próximo de baixo.
        if (this.y + halfSize > this.arena.bottom)
            this.#drawAt(ctx, this.x, this.y - this.worldHeight);

        // CANTOS //

        // Superior esquerdo.
        if (this.x - halfSize < this.arena.left && this.y - halfSize < this.arena.top )
            this.#drawAt(ctx, this.x + this.worldWidth, this.y + this.worldHeight);

        // Superior direito.
        if (this.x + halfSize > this.arena.right && this.y - halfSize < this.arena.top )
            this.#drawAt(ctx, this.x - this.worldWidth, this.y + this.worldHeight);

        // Inferior esquerdo.
        if (this.x - halfSize < this.arena.left && this.y + halfSize > this.arena.bottom )
            this.#drawAt(ctx, this.x + this.worldWidth, this.y - this.worldHeight);

        // Inferior direito.
        if (this.x + halfSize > this.arena.right && this.y + halfSize > this.arena.bottom )
            this.#drawAt(ctx, this.x - this.worldWidth, this.y - this.worldHeight);
    }

    #drawAt(ctx, x, y) {
        ctx.save();
        ctx.globalAlpha=this.opacity;
        ctx.fillStyle="#000000";
        ctx.beginPath();
        ctx.arc(x,y,this.size,0,2*Math.PI);
        ctx.fill();
        ctx.restore();
    }
}
