class Arena {
    constructor(height,width){
        this.height=height;
        this.width=width;

        this.left=0;
        this.right=width;
        this.top=0;
        this.bottom=height;

        const topLeft={x:this.left,y:this.top};
        const topRight={x:this.right,y:this.top};
        const bottomLeft={x:this.left,y:this.bottom};
        const bottomRight={x:this.right,y:this.bottom};
        this.position = {left:this.left, right:this.right, top: this.top, bottom:this.bottom};
    }

    draw(ctx, background){
        ctx.clearRect(0,0,this.width,this.height);
        ctx.drawImage(background, 0, 0, canvas.width, canvas.height);
    }
}
