package
{
    public class EmbeddedAssets
    {
        /** ATTENTION: Naming conventions!
         *  
         *  - Classes for embedded IMAGES should have the exact same name as the file,
         *    without extension. This is required so that references from XMLs (atlas, bitmap font)
         *    won't break.
         *    
         *  - Atlas and Font XML files can have an arbitrary name, since they are never
         *    referenced by file name.
         * 
         */
        
        // Texture Atlas

        [Embed(source="../assets/textures/sheet.xml", mimeType="application/octet-stream")]
        public static const sheet_xml:Class;

        [Embed(source="../assets/textures/sheet.png")]
        public static const sheet:Class;
        
        // Fonts

        [Embed(source="../assets/fonts/Rumpelstiltskin.ttf", embedAsCFF="false", fontFamily="Rumpelstiltskin", unicodeRange="U+0020-U+007e")]
        private static const Rumpelstiltskin:Class;
/*
        [Embed(source = "../assets/fonts/rmpl.png")]
        public static const rmpl:Class;

        [Embed(source="../assets/fonts/rmpl.fnt", mimeType="application/octet-stream")]
        public static const rmplXml:Class;*/
        
        // Sounds
        
        [Embed(source="../assets/audio/chit.mp3")]
        public static const chit:Class;

        [Embed(source="../assets/audio/sparkle.mp3")]
        public static const sparkle:Class;

        // embed configuration XML
        [Embed(source="../assets/particles/particle.pex", mimeType="application/octet-stream")]
        public static const ExplosionConfig:Class;

        // embed particle texture
        [Embed(source = "../assets/particles/texture.png")]
        public static const ExplosionParticle:Class;
    }
}