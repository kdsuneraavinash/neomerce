/**
21 Products
============

pg_dump --table product --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table productimage --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table variant --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table productcategory --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table tag --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table producttag --data-only --column-inserts -U neomerce_app neomerce > data.sql   
**/

INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('5f6aff49-c20b-456d-8938-dea885941365', 'Samsung 128GB 100MB/s (U3) MicroSDXC EVO Select Memory Card with Full-Size Adapter (MB-ME128GA/AM)', 'IDEAL FOR RECORDING 4K UHD VIDEO: Samsung MicroSD EVO is perfect for high-res photos, gaming, music, tablets, laptops, action cameras, DSLR''s, drones, smartphones (Galaxy S10, S10+, S10e, S9, S9+, Note9, S8, S8+, Note8, S7, S7 Edge, etc.), Android devices and more
ULTRA-FAST READ WRITE SPEEDS: Up to 100MB/s read and 90MB/s write speeds; UHS Speed Class U3 and Speed Class 10 (performance may vary based on host device, interface, usage conditions, and other factors)
BUILT TO LAST RELIABILITY: Shock proof memory card is also water proof, temperature proof, x-ray proof and magnetic proof
EXTENDED COMPATIBILITY: Includes full-size adapter for use in cameras, laptops and desktop computers
10-YEAR LIMITED WARRANTY: 10-year limited warranty does not extend to dashcam, CCTV, surveillance camera and other write-intensive uses; Warranty for SD adapter is limited to 1 year', 0.00, 'Samsung', '2019-12-31 21:56:18.212725');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('738426aa-35ea-4d96-b839-d0902d084672', 'Wyze Cam 1080p HD Indoor Wireless Smart Home Camera with Night Vision, 2-Way Audio, Works with Alexa & the Google Assistant, One Pack, White - WYZEC2', 'Live Stream from Anywhere in 1080p -1080p Full HD live streaming lets you see inside your home from anywhere in real time using your mobile device. While live streaming, use two-way audio to speak with your friends and family through the Wyze app.
Motion/Sound Recording with Free Cloud Storage - Wyze Cam can automatically record a 12-second video clip when motion or sound is detected and saves that video to the cloud for 14-days, for free. Mobile push notifications can be enabled so you’re only alerted when something is detected letting you stay on top of things without having to constantly monitor the app. Or, record continuously to a MicroSD card (sold separately) regardless of motion and sound. Compatible with 8GB, 16GB, or 32GB FAT32 MicroSD cards.
See in the dark - Night vision lets you see up to 30’ in absolute darkness using 4 infrared (IR) LEDs. Note: IR does not work through glass windows.
Voice Controlled? You got it! - Works with Alexa and Google Assistant (US only) so you can use your voice to see who’s at your front door, how your baby’s doing, or if your 3D printer has finished printing. Wyze Cam is only compatible with the 2. 4GHz WiFi network (does not support 5GHz Wi-Fi) and Apple (iOS) and Android mobile devices.
Share with those who care - One Wyze Cam can be shared with multiple family members so everyone can have access to its live stream and video recordings. Just have your family members download the Wyze app and invite them to your account. Camera sharing can also be easily removed.', 1.50, 'Wyze', '2019-12-31 22:02:21.602658');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('1f6c20e0-8af5-4ad6-ae98-026bc7741670', 'Nixplay Smart Digital Photo Frame 10.1 Inch - Share Moments Instantly via E-Mail or App', 'AMERICA’S NUMBER ONE SELLING FRAME with over 2 million units sold. Nixplay has been serving America’s families for over 10 years. A great gift for new parents, grandparents, newlyweds, college kids or families separated by distance
SHARE PHOTOS AND VIDEO PRIVATELY, SAFELY: Share images to your loved ones'' frames and invite others to share pictures to your frame; Send unique photos or playlists to separate frames and grow your private family sharing network
PRINT PHOTO SERVICE WITH FUJI: The Nixplay App for iOS and Android gives you full control over your frame; Connect to Google Photos to ensure your frame is always up to date; Dropbox, Facebook and Instagram also supported from website
A WALL-MOUNTABLE SMART FRAME THAT IS TRULY SMART: 1280x800 HD IPS display with 16:10 aspect ratio auto adjusts to portrait or landscape placement; Motion sensor turns the frame on/off automatically; Works with Amazon Alexa, Google Assistant, just ask for the playlist you want
FRIENDLY CUSTOMER CALL SERVICE, EMAIL OR LIVE CHAT: Get support when you need it – even during the Holidays! We have hundreds of thousands of happy customers, and we want to do everything we can to make you happy with your frame', 4.00, 'Nixplay', '2019-12-31 22:15:11.46212');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('18fdb12a-f34f-441e-adf3-01106905e5e5', 'Wyze Cam Pan 1080p Pan/Tilt/Zoom Wi-Fi Indoor Smart Home Camera with Night Vision, 2-Way Audio, Works with Alexa & the Google Assistant, White - WYZECP1', 'Pan, tilt, and zoom (PTZ) lets you control Wyze Cam Pan remotely using the Wyze app so you can see every angle of your room while you’re away, on demand. Or, have Wyze Cam Pan monitor your room automatically with the Pan Scan feature by setting 4 predefined waypoints. Panning has a 360° left/right rotation range and tilting has a 93° vertical up/down range.
Live Stream from Anywhere in 1080p - 1080p Full HD live streaming lets you see inside your home from anywhere in real time using your mobile device. While live streaming, use two-way audio to speak with your friends and family through the Wyze app.
Motion/Sound Recording with Free Cloud Storage - Wyze Cam Pan can automatically record a 12-second video clip when motion or sound is detected and saves that video to the cloud for 14-days, for free. Mobile push notifications can be enabled so you’re only alerted when something is detected letting you stay on top of things without having to constantly monitor the app. Or, record continuously to a MicroSD card (sold separately) regardless of motion and sound. Compatible with 8GB, 16GB, or 32GB FAT32 MicroSD cards.
See in the dark - Night vision lets you see up to 30’ in absolute darkness using 6 infrared (IR) LEDs. Note: IR does not work through glass windows.
Voice Controlled? You got it! - Works with Alexa and Google Assistant (US only) so you can use your voice to see who’s at your front door, how your baby’s doing, or if your 3D printer has finished printing. Wyze Cam Pan is only compatible with the 2. 4GHz WiFi network (does not support 5GHz Wi-Fi) and Apple (iOS) and Android mobile devices.
Share with those who care - One Wyze Cam can be shared with multiple family members so everyone can have access to its live stream and video recordings. Just have your family members download the Wyze app and invite them to your account. Camera sharing can also be easily removed.', 8.00, 'Wyze', '2019-12-31 22:19:03.665441');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('529c3f21-ff14-4976-a8d5-8b56b7bab356', 'SanDisk 128GB Extreme MicroSDXC UHS-I Memory Card with Adapter - C10, U3, V30, 4K, A2, Micro SD - SDSQXA1-128G-GN6MA', 'Up to 160MB/s read speeds to save time transferring high res images and 4K UHD videos (2); Requires compatible devices capable of reaching such speeds
Up to 90MB/s write speeds for fast Shooting; Requires compatible devices capable of reaching such speeds
4K UHD and Full HD Ready(2) with UHS Speed Class 3 (U3) and video Speed Class 30 (V30)(5)
Rated A2 for faster loading and in app Performance (8)
Built for and tested in harsh conditions: temperature Proof, Water Proof, shock Proof and x ray Proof(4)
Get the SanDisk Memory Zone app for Easy file management (available on Google Play)(3)
Manufacturer lifetime Warranty (30 year Warranty in Germany and regions Not recognizing lifetime; See official SanDisk website for more Details regarding Warranty in Your region)
Order with Your Alexa Enabled device; Just ask ''Alexa, order SanDisk microSD''', 0.00, 'SanDisk', '2019-12-31 22:21:50.562829');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('06945798-726c-4ce4-9bb5-ba0ef2da97e9', 'Samsung Galaxy S10 Factory Unlocked Phone with 128GB - Prism Black', 'An immersive Cinematic Infinity Display, Pro grade Camera and Wireless PowerShare The next generation is here
Ultrasonic in display fingerprint ID protects and unlocks with the first touch
Pro grade Camera effortlessly captures epic, pro quality images of the world as you see it
Intelligently accesses power by learning how and when you use your phone. Wi Fi Connectivity 802.11 a/b/g/n/ac/ax 2.4G+5GHz, HE80, MIMO, 1024 QAM. Wi Fi Direct Yes', 0.00, 'Samsung', '2019-12-31 22:40:11.566452');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('4ca81e74-fa61-4747-851c-9212457aebfb', 'Google - Pixel 3a with 64GB Memory Cell Phone (Unlocked) - Just Black - G020G', 'Capture stunning photos with features like night sight, portrait mode, and HDR+.
Save every photo with free, unlimited storage at high quality through Google photos [1].
The Google assistant is the easiest way to get things done – including screening calls.[2]
Fast Charging battery delivers up to 7 hours of use with just a 15-minute charge.[3]
Comes with 3 years of OS and security updates] and the custom-built Titan M chip.[5]
Switch seamlessly and keep all your stuff [6]. Plus your favorite Google apps are built in.', 0.00, 'Google Pixel', '2019-12-31 22:44:41.560134');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('3ec1789e-f976-4e3e-84bf-ac0b566b4189', 'Samsung Galaxy A50 US Version Factory Unlocked Cell Phone with 64GB Memory, 6.4 Screen, Black, [SM-A505UZKNXAA]', 'With an all day battery that lasts up to 35 hours, The Galaxy A50 keeps up with your fast pace throughout the day and into the night; When you need a boost, power back up quickly with fast charging
Featuring three specialized lenses, The Galaxy A50 is the only camera you’ll ever need; Capture more of what you see in every shot, thanks to our advanced Ultra wide 123 degrees field of vision; Shoot vibrant photos with a 25MP Main Camera or take flattering selfies with a depth lens that puts the focus squarely on you by softening the background', 0.00, 'Samsung', '2019-12-31 22:47:00.165348');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', 'Moto G7 – Unlocked – 64 GB – Ceramic Black (US Warranty) - Verizon, AT&T, T-Mobile, Sprint, Boost, Cricket, & Metro', 'Unlocked for the freedom to choose your carrier. Compatible with AT&T, Sprint, T-Mobile, and Verizon networks. Sim card not included. Customers may need to contact Sprint for activation on Sprint’s network.
6. 2" Full HD+ Max Vision display (2270 x 1080) with 19: 9 Aspect ratio, 4 GB of RAM and 64 GB of internal storage with option to add up to 512 GB of Micro SD expandable memory, and Android 9. 0.
Qualcomm Snapdragon 632 processor with 1. 8 GHz Octa-Core CPU and Adreno 506 GPU.
12MP + 5MP dual camera with LED flash, 8 MP front-facing camera with screen flash for low light selfies.
3, 000 mAh non-removable battery with USB Type-C 18W charger.
Facial recognition and fingerprint sensor to instantly unlock your phone.
Reliable design: water protection design with IP54, enjoy a comfortable grip with a scratch-resistant, contoured 3D Corning Gorilla glass design.
Operating System: Android', 0.00, 'Unbranded', '2019-12-31 22:53:03.75859');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('48549fd0-d87c-4d63-8728-a44cea1cad4d', 'Apple iPhone 8, 64GB, Gold - Fully Unlocked (Renewed)', 'Product works and looks like new. Backed by the 90-day Amazon Renewed Guarantee.
Renewed products work and look like new. These pre-owned products are not Apple certified but have been inspected and tested by Amazon-qualified suppliers. Box and accessories (no headphones included) may be generic. Wireless devices come with the 90-day Amazon Renewed Guarantee. Learn more
4.7-Inch (diagonal) widescreen LCD multi-touch display with IPS technology and Retina HD display
12MP camera with Optical image stabilization and Six-element lens
4K video recording at 24 fps, 30 fps, or 60 fps
Rated IP67 (maximum depth of 1 meter up to 30 minutes) under IEC standard 60529
A11 Bionic chip Neural Engine', 0.00, 'Apple', '2019-12-31 23:09:51.069478');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', 'GlocalMe G4 4G LTE Mobile Hotspot, Worldwide High Speed WiFi Hotspot with 1GB Global Data & 8GB US Data, No SIM Card Roaming Charges International Pocket WiFi Hotspot MIFI Device - Black', '【1.1GB initial Global Data & 8GB North America Data】GlocalMe G4 comes with 1.1GB global data（1 year validity). And the 8GB North America Data can be used in USA, Canada and Mexico, please contact seller to activate by offer your Imei number.
【Lastest Version of GlocalMe】GlocalMe G4 is the upgraded version of G3. Not only Provides an reliable and ultra fast 4G Internet, Moreover, comes with some very useful App for Trip such as TripAdvisor. Work for 15 hours with 3900mAh battery which could also recharge your smartphone on the road.All of our Self shipment Item are delivered by UPS, it only takes around 3 days to reach you after delivery.
【Perfect Travel Wi-Fi Hotspot】GlocalMe allows travelers to get online in over 140 countries and regions without any SIM cards. You don''t need to wait in line or rent mobile routers but enjoy a super-fast and stable 4G internet at the speed of 150 Mbps download/50 Mbps upload. For detailed coverage information please pay a visit to our website: www.glocalme.com.
【Unlocked to all networks】Connect up to 5 Wi-Fi enabled gadgets including your laptop, smart phone, kindle plus more, acts like your personal reliable and secure Wi-Fi hotspot. Moreover, via the user-friendly App, you can easily manage and purchase extra data packages at a low cost if you need, such as 1GB for US is about $ 6 . No contract or roaming charge, only pay for the exact data you used.
【Multifunctional Slot Design & User-friendly App 】G4 also works as a traditional unlocked Wi-Fi hotspot with two SIM card slots. With GlocalMe App, you could manage your data smartly by topping up your balance, purchasing data packages and easily track detailed interaction with the data', 1.00, 'Unbranded', '2019-12-31 23:15:37.003829');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', 'Netgear Unite AC770S | Mobile Wifi Hotspot 4G LTE | Up to 300Mbps Download Speed | Connect Up to 10 Devices | Create A WLAN Anywhere | 2 MIMO TS-9 external antenna connectors | GSM Unlocked - White', 'OES THIS DEVICE NEED A SIM CARD: Yes it does Being that this device is GSM unlocked it will work on any GSM Network with a Standard size SIM Card (This is the Larges size sim card) The sim card does NOT come included and you will need to contact your Network Provider to acquire your complimentary Sim card (Free from most Carriers with activating of an account)
WHAT NETWORK FREQUENCIES ARE SUPPORTED BY THIS DEVICE: This device will support B17 (700) and B4 (1700/2100) on the 4G Spectrum. and B5 (850), and B2 (1900) on the 3G Spectrum.
HOW LONG CAN I EXPECT THE BATTERY TO LAST ME: Well the battery has 2500mAh which in a Usage time frame means 10 solid hours of Usage streaming at 4G LTE speeds as well it has a Standby time of up to 10 days before you need to recharge the battery
WHAT DOES UNLOCKED REALLY MEAN: Unlocked devices are compatible with GSM carriers the kinds that Use SIM Cards for Service like AT&T and T-Mobile as well as with GSM SIM cards (e.g. H20, Straight Talk, and select prepaid carriers) Unlocked Devices will not work with CDMA Carriers the kinds that dont use sim cards for service like Sprint, Verizon, Boost or Virgin
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WILL NOT WORK ON VERIZON OR SPRINT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', 0.00, 'Unbranded', '2019-12-31 23:18:31.300932');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('ac616902-6f70-4fff-85fc-2e46ed0e3d7e', 'Alcatel LINKZONE | Mobile WiFi Hotspot | 4G LTE Router MW41TM | Up to 150Mbps Download Speed | WiFi Connect Up to 15 Devices | Create A WLAN Anywhere | T-Mobile', 'DOES THIS DEVICE NEED A SIM CARD: Yes it does Being that this device is T-Mobile it will work on any T-Mobile with a Micro size ACTIVE SIM Card The sim card does not come included, you will need to contact T-Mobile to acquire your complimentary Sim card (activating on T-Mobile Costs Approx $10 at any T-Mobile Store or over the phone).
WHAT NETWORK FREQUENCIES ARE SUPPORTED BY THIS DEVICE: The device supports Bands FDD LTE: B2/4/12 WCDMA: B1/2/4/5 GSM: B2/3/5/8. Please contact T-Mobile and inquire whether they support these bands in your area to ensure the device will work Properly
WELL, HOW LONG CAN IT LAST ME: A removable 1,800mAh battery that lasted for 6 hours of continuous streaming in our tests that''s reasonable for a Small slick hotspot as well as a STANDBY TIME of 300 hours.
This device will not work on any other network besides of the T-Mobile network it is a T-Mobile branded device and will only function for their Network, A mobile hotspot provides Wi-Fi to up to 15 devices within 150 ft so that they can all access Internet on the blazingly fast 4G LTE Spectrum
IS THIS DEVICE UNLOCKED: No. this device will be locked unto the T-Mobile Network for the first 2 Years after that period you can contact T-Mobile to Unlock the device. THIS DEVICE WILL ONLY WORK ON THE T-Mobile NETWORK OUT OF THE BOX.', 1.00, 'Alcatel', '2019-12-31 23:25:56.389156');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('c6f66840-acfd-4e18-8a45-100138e4c54b', 'Alcatel Link Zone 4G LTE Global MW41NF-2AOFUS1 Mobile Wifi Hotspot Factory Unlocked GSM Up to 15 Wifi Users USA Latin Caribbean Europe MW41NF', '4G LTE Unlocked GSM Carrier Desbloqueados GSM (Router Does NOT Work on Verizon Sprint Net10 or Any CDMA Carrier)
Factory Unlocked "NO LOGOS" 1 Micro Sim Card 4G Lte bands:B1 (2100) B2 (1900) B3 (1800) B4 (AWS) B5 (850) B7 (2600) B8 (900) B12 (700) B13 (700) B20 (800) 3G UTMS: 850/900/1700/1900/2100 2G: 850/900/1800/1900 MHZ
4G LTE WORLDWIDE Up to 150 MBPS and 15 Wifi Users / Cat 4 / Spanish English Interface
Router uses Micro Sim Card Hotspot Service is required. (No sim card or Services included).
Wi-Fi Specs 802.11 b/g/n – 2.4 GHz Use the hotspot with up to 15 different wifi devices including laptops, iPhone, smartphone, iPad, tablet, gaming consoles and many more.', 1.00, 'Alcatel', '2019-12-31 23:30:07.450814');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('6f066264-fee9-4d75-8640-f9047e1b5904', 'Verizon Jetpack 4G LTE Mobile Hotspot - AC791L With Accessory Port (Renewed) Includes JPO Car Bullet charger head', 'Product works and looks like new. Backed by the 90-day Amazon Renewed Guarantee.

Renewed products work and look like new. These pre-owned products have been inspected and tested by Amazon-qualified suppliers. Box and accessories (no headphones included) may be generic. Wireless devices come with the 90-day Amazon Renewed Guarantee. Learn more

4G LTE Advanced-capable device for ultimate download speeds
Up to 24 hours of battery life on a single charge
Charge your smartphone or small portable USB device
Secure with Guest WiFi, password protection, and the latest WiFi security
World Device for easy Internet access when traveling internationally', 1.00, 'Verizon', '2019-12-31 23:31:21.480522');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('e6965dfc-6775-4e81-8ab2-bafbe1534530', 'CanaKit Raspberry Pi 3 B+ (B Plus) with 2.5A Power Supply (UL Listed)', 'Includes Raspberry Pi 3 B+ (B Plus) with 1.4 GHz 64-bit Quad-Core Processor, 1 GB RAM
CanaKit 2.5A USB Power Supply with Micro USB Cable and Noise Filter - Specially designed for the Raspberry Pi 3 B+ (UL Listed)
Dual Band 2.4GHz and 5GHz IEEE 802.11.b/g/n/ac Wireless LAN, Enhanced Ethernet Performance
Set of 2 Aluminum Heat Sinks
CanaKit Quick-Start Guide', 1.50, 'Unbranded', '2019-12-31 23:44:07.813207');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', 'Corsair One i164 Compact Gaming PC, i9-9900K, Liquid-Cooled RTX 2080 Ti, 960GB M.2, 2TB HDD, 32GB', 'Corsair One i164 redefines what you can expect from a high performance PC. Incredibly fast, amazingly compact, and quiet, With a sophisticated design that lives on your desk, not under it.
Corsair One i164 boasts the latest in performance PC technology, with an Intel Core i9-9900k Eight-Core Processor, NVIDIA GeForce RTX 2080 Ti graphics and award-winning Corsair DDR4 memory.
Clad in a 2mm thick bead-blasted aluminum shell. Corsair ONE i164’s minimalist ultra-small form factor is crafted to sit on top of your desk, not under it.
Zero RPM mode allows for quiet fanless operation when idle. Form Factor Mini-ITX
Corsair One i164’s processor and graphics card are cooled using a patented assisted convection liquid cooling system, achieving higher clock speeds, lower temperatures, and minimal noise.', 5.90, 'Corsair', '2019-12-31 23:46:16.724689');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('45ee0b20-0530-4d90-b8e6-1bb406d8e870', 'ASRock System DESKMINI A300W AMD AM4 Max.32GB DDR4 HDMI DP D-Sub USB Retail', 'Supports AMD AM4 socket CPUs (Raven Ridge, Bristol Ridge, up to 65W)
Supports AMD AM4 CPU cooler (Max. Height ≦ 46mm)
Mad A300 Promontory
2x 2. 5” SATA6Gb Hard Drive
1 x M. 2 (key E 2230) slot for Wi-Fi + BT module', 3.00, 'Unbranded', '2019-12-31 23:57:51.035079');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('22ef01c0-af1e-4087-ade5-1e547e59c4d2', 'Intel NUC Kit NUC6i5SYK', '6th generation Intel Core i5-6260U
Intel Iris graphics 540
Up to 7.1 surround audio via HDMI and Mini DisplayPort
Internal support for M.2 SSD card (22x42 or 22x80)
Support for user-replaceable 3rdparty lids
Intel Wireless-AC 8260 M.2 soldered-down, wireless antennas (IEEE 802.11ac, Bluetooth 4.1, Intel Wireless Display 6.0)
19V, 65W wall-mount AC-DC power adapter
Multi-country plugs(US, UK, EU, AU)', 6.00, 'Intel', '2020-01-01 00:08:54.973785');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('43656a7f-e326-443a-b91b-54c31d6ca2e3', 'Thermaltake Core G3 Black Slim Small Form Factor ATX Perforated Metal Front and Top Panel Gaming Computer Case with Two 120mm Front Fan Pre-Installed CA-1G6-00S1WN-A0', 'Stay slim: A perfect compact micro slim chassis design fit at your desk or living room
Dual placements layout: Designed for horizontal or Vertical layouts, the Core G3 takes both angles for even more
Lan party ready: GPU padded braces and travel foams to secure your hardware while traveling
Floating GPU design: Bring your GPU power to the forefront With a custom GPU mount, turning the GPU face front for an unprecedented look
Fully modular: Provides multiple configurations and flexibility for custom PC enthusiasts
2 Drive bay: 2. 5"/3. 5” x 2 with HDD cage
Optimize system ventilation: 2 120mm front fan pre installed', 2.90, 'Unbranded', '2020-01-01 00:11:23.904866');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', 'WD 2TB Elements Portable External Hard Drive - USB 3.0 - WDBU6Y0020BBK', 'USB 3.0 and USB 2.0 Compatibility
Fast data transfers
Improve PC Performance
High Capacity; Compatibility Formatted NTFS for Windows 10, Windows 8.1, Windows 7; Reformatting may be required for other operating systems; Compatibility may vary depending on user’s hardware configuration and operating system
2 year manufacturer''s limited warranty', 0.50, 'WD', '2020-01-01 00:19:27.690199');
-- Products

INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('632b7e2e-b315-43bb-b7cc-441232c37eee', '5f6aff49-c20b-456d-8938-dea885941365', 'https://images-na.ssl-images-amazon.com/images/I/817wkPGulTL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('569efeb9-41a1-46c6-94b7-9480a72f2a41', '5f6aff49-c20b-456d-8938-dea885941365', 'https://images-na.ssl-images-amazon.com/images/I/61kxjADwqlL._AC_SL1000_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('3d52766d-edc3-4dec-a427-0186348b9191', '5f6aff49-c20b-456d-8938-dea885941365', 'https://images-na.ssl-images-amazon.com/images/I/815KXesPOtL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('ddfa3aa4-2971-40ba-a72b-de1caf380e02', '738426aa-35ea-4d96-b839-d0902d084672', 'https://images-na.ssl-images-amazon.com/images/I/51H5U1Q8RRL._AC_SL1234_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('7b93e759-7126-40a4-b2ed-b6da103fe2dc', '738426aa-35ea-4d96-b839-d0902d084672', 'https://images-na.ssl-images-amazon.com/images/I/61jV1-4PxXL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('6f923089-8442-4df6-8f5a-d71ebfd0674a', '738426aa-35ea-4d96-b839-d0902d084672', 'https://images-na.ssl-images-amazon.com/images/I/61RqrX5A2OL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('18f6bb90-f6d8-42ed-bd59-4c7cc0c833f0', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', 'https://images-na.ssl-images-amazon.com/images/I/81g-euOr3%2BL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('45d8a5bc-0ef5-4f54-ad58-46414ad64634', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', 'https://images-na.ssl-images-amazon.com/images/I/71wYKCierZL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('c4caf2ae-d3e7-410b-878b-ab26ee5606c6', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', 'https://images-na.ssl-images-amazon.com/images/I/71PhTotGCOL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('8a71ecd1-b873-49dd-aea6-ca3d3dfeb0a1', '18fdb12a-f34f-441e-adf3-01106905e5e5', 'https://images-na.ssl-images-amazon.com/images/I/31dz6wCIWML._AC_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('615e6ba4-a15a-4071-8685-822e4b11b627', '18fdb12a-f34f-441e-adf3-01106905e5e5', 'https://images-na.ssl-images-amazon.com/images/I/31Y8NH8Ia5L._AC_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('86d7590d-d4f8-4b45-a495-eb21d8655078', '529c3f21-ff14-4976-a8d5-8b56b7bab356', 'https://images-na.ssl-images-amazon.com/images/I/71f0i4j9wGL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('2e2b228d-5a43-4704-ac7f-58b73f66ff69', '529c3f21-ff14-4976-a8d5-8b56b7bab356', 'https://images-na.ssl-images-amazon.com/images/I/81PC94JVGkL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('7c8bc11e-3186-4dc3-99bc-09c886d014d9', '529c3f21-ff14-4976-a8d5-8b56b7bab356', 'https://images-na.ssl-images-amazon.com/images/I/81DAzeX7Z4L._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('6c0415c1-ff1e-435b-87f1-2df34230173e', '06945798-726c-4ce4-9bb5-ba0ef2da97e9', 'https://images-na.ssl-images-amazon.com/images/I/51x8eZ8JbKL._AC_SL1000_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('a7058605-b2ee-4216-beb7-dbf71c62d83d', '4ca81e74-fa61-4747-851c-9212457aebfb', 'https://images-na.ssl-images-amazon.com/images/I/81T-FKC695L._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('b425c44d-f961-4f44-8c4c-1acfebcab4ec', '3ec1789e-f976-4e3e-84bf-ac0b566b4189', 'https://images-na.ssl-images-amazon.com/images/I/71kLFOLKN3L._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('9154782d-605c-4dc8-be67-6dca209ec2aa', '9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', 'https://images-na.ssl-images-amazon.com/images/I/81Vobb06FVL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('9d13c23b-91fd-47f9-a721-18a6a67c136f', '06945798-726c-4ce4-9bb5-ba0ef2da97e9', 'https://images-na.ssl-images-amazon.com/images/I/61GUOlgK7GL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('819f36b6-5e83-4831-add5-0e127b1d880d', '48549fd0-d87c-4d63-8728-a44cea1cad4d', 'https://images-na.ssl-images-amazon.com/images/I/61pRPj%2B-IYL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('e18214e6-481b-4430-b86d-0d98c21763b0', '9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', 'https://images-na.ssl-images-amazon.com/images/I/41J545bt3JL._AC_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('c0c85697-17da-4dde-ab35-143e1aaed306', '86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', 'https://images-na.ssl-images-amazon.com/images/I/51a6d27Dc%2BL._AC_SL1049_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('eff0f075-840d-4a68-9f25-70fe1cefdd1f', 'ac616902-6f70-4fff-85fc-2e46ed0e3d7e', 'https://images-na.ssl-images-amazon.com/images/I/61cMxSggndL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('008d401a-02be-4177-9f51-1230f82f1b6b', 'c6f66840-acfd-4e18-8a45-100138e4c54b', 'https://images-na.ssl-images-amazon.com/images/I/71sXcEUxlqL._AC_SL1300_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('5c9cbeba-69e0-4f29-bf80-5a76796c6fba', '6f066264-fee9-4d75-8640-f9047e1b5904', 'https://images-na.ssl-images-amazon.com/images/I/412BQqDj9UL._AC_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('7d93f7e3-9843-4d74-bd03-7ba2a48cc83f', 'e6965dfc-6775-4e81-8ab2-bafbe1534530', 'https://images-na.ssl-images-amazon.com/images/I/817pW0tRRuL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('6748056b-2a67-46ad-bb90-cf285174e103', '78f1645e-8694-4e36-93e8-5f14dea416b8', 'https://images-na.ssl-images-amazon.com/images/I/61fBJ-%2BRONL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('8af781b1-f447-4b77-abfd-6b2f005b13ce', '78f1645e-8694-4e36-93e8-5f14dea416b8', 'https://images-na.ssl-images-amazon.com/images/I/71MtOi5vpRL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('d343fddc-b360-42a5-bbc7-3aba99210a2b', '78f1645e-8694-4e36-93e8-5f14dea416b8', 'https://images-na.ssl-images-amazon.com/images/I/71MtOi5vpRL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('66063d61-ba24-4ea9-b273-0a3bb4f1ef72', '45ee0b20-0530-4d90-b8e6-1bb406d8e870', 'https://images-na.ssl-images-amazon.com/images/I/61rxF7qctmL._AC_SL1200_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('56e90d1b-a4c0-4060-a273-d3101d48c59b', '22ef01c0-af1e-4087-ade5-1e547e59c4d2', 'https://images-na.ssl-images-amazon.com/images/I/619unAHNLqL._AC_SL1490_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('f85fe6f8-b92c-4d38-a2b2-2868a50603cd', '43656a7f-e326-443a-b91b-54c31d6ca2e3', 'https://images-na.ssl-images-amazon.com/images/I/81wF0U6-PmL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('df4338f2-2ae5-4fc9-9605-88a41bd153d8', '43656a7f-e326-443a-b91b-54c31d6ca2e3', 'https://images-na.ssl-images-amazon.com/images/I/81ROx1BIb%2BL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('fa973739-6e75-4401-b44d-6e08ce227f63', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', 'https://images-na.ssl-images-amazon.com/images/I/61AjtL1R%2BgL._AC_SL1500_.jpg');
-- Images

INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('39fdcf10-c37d-434e-9ace-3854e0af4c0a', '5f6aff49-c20b-456d-8938-dea885941365', '1577808562', 50, '128 GB', 4250.00, 4000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('38af28dc-cfb2-4493-b863-2862344ea69f', '5f6aff49-c20b-456d-8938-dea885941365', '15778085622', 56, '256 GB', 9000.00, 8500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('efd7b85d-b897-420b-a165-e53f79f174ff', '738426aa-35ea-4d96-b839-d0902d084672', '1577809888', 54, 'One Pack', 4600.00, 4300.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('849d0f81-11fe-431b-9290-1990d1ed1265', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', '575686111R', 9, '13.3 Inch', 33000.00, 29950.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('f590db01-d29f-4044-8232-7f203a7adb7d', '18fdb12a-f34f-441e-adf3-01106905e5e5', '662382858', 56, 'Default', 45000.00, 42000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('4690dfa6-4d44-423e-becb-ac0ca897c594', '529c3f21-ff14-4976-a8d5-8b56b7bab356', '757506702R', 56, '256 GB', 8600.00, 7500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('13344e0c-f7e8-4de7-a224-c8ef3332ad60', '738426aa-35ea-4d96-b839-d0902d084672', '1577809888R', 10, 'One Pack + SD Card', 5900.00, 5850.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('fe190bc9-0a2c-4774-bbf1-8b66e07af1f3', '738426aa-35ea-4d96-b839-d0902d084672', '1577809888S', 4, 'Two Pack Camera', 18000.00, 16999.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('b0b91471-18b8-425f-9e20-8bea7fdaa751', '06945798-726c-4ce4-9bb5-ba0ef2da97e9', '591827728R', 8, 'S10e', 135000.00, 120000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('c815c070-56d6-472c-ae24-76a249c9bede', '06945798-726c-4ce4-9bb5-ba0ef2da97e9', '591827728', 4, 'S10', 120000.00, 112000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('1d9b0bbb-fbf7-4c40-b326-85a6e064655e', '4ca81e74-fa61-4747-851c-9212457aebfb', '870747987', 2, '3A', 90000.00, 78000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('04aa1f0c-35b6-4f8a-bec9-a4eb3e8d0950', '3ec1789e-f976-4e3e-84bf-ac0b566b4189', '991851629', 3, 'A50', 68000.00, 66000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('e82c2fbc-365a-439d-ab5d-c1e138bfa0de', '9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', '812738244', 56, 'G7', 25000.00, 22500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('96aa2f9d-b6fe-4860-86ac-789a91569a4b', '9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', '812738244T', 65, 'G7 Play', 29000.00, 28500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('43282f65-922f-490b-8c1a-309c929ceb2a', '48549fd0-d87c-4d63-8728-a44cea1cad4d', '477545419', 5, '64 GB', 48000.00, 45000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('fe58f106-37a3-40b9-9a05-bf1ed2d09da7', '9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', '298253076', 5, 'Default', 220000.00, 199000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('d1444c76-1ce6-47a2-b202-676310cc93f9', 'ac616902-6f70-4fff-85fc-2e46ed0e3d7e', '940567204', 99, 'Default', 78000.00, 75000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('5e131d01-74c9-41db-b2bc-77875162919d', 'c6f66840-acfd-4e18-8a45-100138e4c54b', '379803353', 20, 'Default', 75000.00, 70000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('5a4f6a69-d1d7-404e-856a-b405c1ecce7a', '6f066264-fee9-4d75-8640-f9047e1b5904', '187195688', 10, 'Default', 7500.00, 7000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('9c1933ba-d4bd-46e4-8a8e-312a865850bd', '86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', '910039752', 4, 'Default', 68000.00, 64000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('a2a8fc3e-0e66-4d91-a124-f85cfb8d8ba6', 'e6965dfc-6775-4e81-8ab2-bafbe1534530', '651316561', 5, 'Default', 8000.00, 7500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('16e975e2-8b6f-45c8-af72-4795b5b0ba0b', '78f1645e-8694-4e36-93e8-5f14dea416b8', '451495971R', 0, 'i9-9920X - 32 GB DRAM', 650000.00, 599900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('8405292a-6720-46d2-afea-62bda36ddafb', '78f1645e-8694-4e36-93e8-5f14dea416b8', '451495971X', 2, 'i9-9920X - 64GB DRAM', 780000.00, 749050.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('09c0f1c8-b576-4f19-8e85-d5efa21d2940', '45ee0b20-0530-4d90-b8e6-1bb406d8e870', '670805553', 20, 'Default', 22000.00, 19900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('0a47fdbf-47f8-4783-8a31-4f4f2bc314ee', '78f1645e-8694-4e36-93e8-5f14dea416b8', '451495971', 4, '  i9-9900K - 32GB DRAM', 650000.00, 599000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('0b39b5e2-1c59-41f0-9a67-fbc479f83d19', '529c3f21-ff14-4976-a8d5-8b56b7bab356', '757506702', 13, '128 GB', 4000.00, 3750.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('06fdbe95-ac66-4184-8782-dab7cd18570c', '22ef01c0-af1e-4087-ade5-1e547e59c4d2', '395822611', 5, 'Default', 70000.00, 68500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('9cd23c74-279f-433b-832c-2a115d423f58', '43656a7f-e326-443a-b91b-54c31d6ca2e3', '395822611R', 5, 'G3', 13000.00, 11900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('31af930d-de0a-46e0-b6e3-6ca3ebeb2345', '43656a7f-e326-443a-b91b-54c31d6ca2e3', '395822611T', 5, 'X31', 16000.00, 12500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('34381d8c-8fc6-49ad-86bd-a6807468a5e9', '43656a7f-e326-443a-b91b-54c31d6ca2e3', '395822611RGB', 0, 'X31 RGB', 19000.00, 17900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('8c3ad6b2-f4ba-4bc5-ab44-db3f8683877e', '43656a7f-e326-443a-b91b-54c31d6ca2e3', '39582261121', 5, 'G21', 21000.00, 19900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('bd37442d-d2dd-48f0-97f7-dca900dcea9c', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', '575686111', 21, '10.1 Inch', 25000.00, 22950.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('2ef51cc5-5368-4131-84d2-4e1b0f95996a', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '187801461', 5, '1TB', 8500.00, 8300.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('03c9e865-6bec-47b5-aa3e-1c6030be0773', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '187801461RT', 6, '2TB', 10000.00, 9800.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('f0b56e42-3309-4959-9347-73d8acab81b1', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '1878014614TB', 5, '4TB', 14000.00, 12800.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('e4d391d0-c26e-4889-95ef-9200a35b26b4', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '1878014618TB', 8, '8TB', 19500.00, 18900.00);
-- Variant

INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '5f6aff49-c20b-456d-8938-dea885941365');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '738426aa-35ea-4d96-b839-d0902d084672');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '1f6c20e0-8af5-4ad6-ae98-026bc7741670');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '18fdb12a-f34f-441e-adf3-01106905e5e5');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '529c3f21-ff14-4976-a8d5-8b56b7bab356');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', '9ece6c0b-7c80-4c3c-afe1-33abfcd52fac');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', '86b4d6b3-ce8c-46fe-92c6-13c5310a43b9');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', '6f066264-fee9-4d75-8640-f9047e1b5904');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', 'ac616902-6f70-4fff-85fc-2e46ed0e3d7e');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', 'c6f66840-acfd-4e18-8a45-100138e4c54b');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '06945798-726c-4ce4-9bb5-ba0ef2da97e9');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '4ca81e74-fa61-4747-851c-9212457aebfb');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '3ec1789e-f976-4e3e-84bf-ac0b566b4189');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '9e1c2494-fcb6-4af6-9b3c-16c1695c32c7');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '48549fd0-d87c-4d63-8728-a44cea1cad4d');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', 'e6965dfc-6775-4e81-8ab2-bafbe1534530');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', '78f1645e-8694-4e36-93e8-5f14dea416b8');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', '45ee0b20-0530-4d90-b8e6-1bb406d8e870');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', '22ef01c0-af1e-4087-ade5-1e547e59c4d2');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', '43656a7f-e326-443a-b91b-54c31d6ca2e3');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b2e8eff4-3e64-4ef6-9705-1b2f106ba363', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2');
-- Categories

INSERT INTO public.tag (tag_id, tag) VALUES ('52fd88ca-b9ba-4ba3-81fb-05c2dffad9f6', 'memory');
INSERT INTO public.tag (tag_id, tag) VALUES ('c1fff244-dfb0-4ed0-8433-6066b7f8fca7', 'card');
INSERT INTO public.tag (tag_id, tag) VALUES ('6ab6980f-c2d1-4e46-8bfb-958fe8f527e4', 'sd');
INSERT INTO public.tag (tag_id, tag) VALUES ('466db086-e1d2-49ca-8133-6489eca0fa69', 'camera');
INSERT INTO public.tag (tag_id, tag) VALUES ('7361a39e-4205-4cbe-8a48-62a762fa4b1d', 'security');
INSERT INTO public.tag (tag_id, tag) VALUES ('d73d96d9-0b90-42f2-963e-07c6d3d157ad', 'privacy');
INSERT INTO public.tag (tag_id, tag) VALUES ('c8ceb7bd-2090-41e7-a9a6-af657abb62de', 'mobile');
INSERT INTO public.tag (tag_id, tag) VALUES ('65e6deda-4dd6-41bd-8c63-5a5f96561712', 'phone');
INSERT INTO public.tag (tag_id, tag) VALUES ('de2d616d-8d5f-4323-8b43-53d95ffe0013', 'internet');
INSERT INTO public.tag (tag_id, tag) VALUES ('987b2540-5ef1-4963-95a7-2dcce5dcf97c', 'connect');
INSERT INTO public.tag (tag_id, tag) VALUES ('c2c37357-fb20-4e74-87fd-a96153dc5238', 'network');
INSERT INTO public.tag (tag_id, tag) VALUES ('bd1a378b-f198-4fe6-9776-0414cc421038', 'connection');
INSERT INTO public.tag (tag_id, tag) VALUES ('873c360f-73b5-42b1-b7de-6e839b782888', 'gaming');
INSERT INTO public.tag (tag_id, tag) VALUES ('08846a00-e6f8-4474-ab95-83486f701b8c', 'workstation');
INSERT INTO public.tag (tag_id, tag) VALUES ('dc9bff23-f812-48ff-8da5-36119254fabb', 'games');
INSERT INTO public.tag (tag_id, tag) VALUES ('b38f667d-3676-41df-87ee-e5be3c49a14c', 'pc');
INSERT INTO public.tag (tag_id, tag) VALUES ('d09dd9a9-d754-4f32-a2ca-5076293e4002', 'case');
INSERT INTO public.tag (tag_id, tag) VALUES ('d79c919d-7f55-41fc-bcce-5fd3ba8d1ef5', 'hard');
INSERT INTO public.tag (tag_id, tag) VALUES ('8b7e845a-3359-4e5a-83e8-a37127582028', 'disk');
-- Tags

INSERT INTO public.producttag (product_id, tag_id) VALUES ('5f6aff49-c20b-456d-8938-dea885941365', '52fd88ca-b9ba-4ba3-81fb-05c2dffad9f6');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('5f6aff49-c20b-456d-8938-dea885941365', 'c1fff244-dfb0-4ed0-8433-6066b7f8fca7');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('5f6aff49-c20b-456d-8938-dea885941365', '6ab6980f-c2d1-4e46-8bfb-958fe8f527e4');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('738426aa-35ea-4d96-b839-d0902d084672', '466db086-e1d2-49ca-8133-6489eca0fa69');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('738426aa-35ea-4d96-b839-d0902d084672', '7361a39e-4205-4cbe-8a48-62a762fa4b1d');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('738426aa-35ea-4d96-b839-d0902d084672', 'd73d96d9-0b90-42f2-963e-07c6d3d157ad');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('1f6c20e0-8af5-4ad6-ae98-026bc7741670', '466db086-e1d2-49ca-8133-6489eca0fa69');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('1f6c20e0-8af5-4ad6-ae98-026bc7741670', '52fd88ca-b9ba-4ba3-81fb-05c2dffad9f6');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('18fdb12a-f34f-441e-adf3-01106905e5e5', '466db086-e1d2-49ca-8133-6489eca0fa69');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('18fdb12a-f34f-441e-adf3-01106905e5e5', '7361a39e-4205-4cbe-8a48-62a762fa4b1d');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('18fdb12a-f34f-441e-adf3-01106905e5e5', 'd73d96d9-0b90-42f2-963e-07c6d3d157ad');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('529c3f21-ff14-4976-a8d5-8b56b7bab356', '52fd88ca-b9ba-4ba3-81fb-05c2dffad9f6');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('529c3f21-ff14-4976-a8d5-8b56b7bab356', '6ab6980f-c2d1-4e46-8bfb-958fe8f527e4');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('529c3f21-ff14-4976-a8d5-8b56b7bab356', 'c1fff244-dfb0-4ed0-8433-6066b7f8fca7');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('06945798-726c-4ce4-9bb5-ba0ef2da97e9', 'c8ceb7bd-2090-41e7-a9a6-af657abb62de');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('06945798-726c-4ce4-9bb5-ba0ef2da97e9', '65e6deda-4dd6-41bd-8c63-5a5f96561712');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('4ca81e74-fa61-4747-851c-9212457aebfb', 'c8ceb7bd-2090-41e7-a9a6-af657abb62de');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('4ca81e74-fa61-4747-851c-9212457aebfb', '65e6deda-4dd6-41bd-8c63-5a5f96561712');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('3ec1789e-f976-4e3e-84bf-ac0b566b4189', 'c8ceb7bd-2090-41e7-a9a6-af657abb62de');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('3ec1789e-f976-4e3e-84bf-ac0b566b4189', '65e6deda-4dd6-41bd-8c63-5a5f96561712');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', 'c8ceb7bd-2090-41e7-a9a6-af657abb62de');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', '65e6deda-4dd6-41bd-8c63-5a5f96561712');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', 'de2d616d-8d5f-4323-8b43-53d95ffe0013');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', '987b2540-5ef1-4963-95a7-2dcce5dcf97c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', 'c2c37357-fb20-4e74-87fd-a96153dc5238');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', '987b2540-5ef1-4963-95a7-2dcce5dcf97c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('ac616902-6f70-4fff-85fc-2e46ed0e3d7e', 'bd1a378b-f198-4fe6-9776-0414cc421038');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('c6f66840-acfd-4e18-8a45-100138e4c54b', 'bd1a378b-f198-4fe6-9776-0414cc421038');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('6f066264-fee9-4d75-8640-f9047e1b5904', 'bd1a378b-f198-4fe6-9776-0414cc421038');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', '873c360f-73b5-42b1-b7de-6e839b782888');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', '08846a00-e6f8-4474-ab95-83486f701b8c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', 'dc9bff23-f812-48ff-8da5-36119254fabb');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', 'b38f667d-3676-41df-87ee-e5be3c49a14c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('45ee0b20-0530-4d90-b8e6-1bb406d8e870', 'd09dd9a9-d754-4f32-a2ca-5076293e4002');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('43656a7f-e326-443a-b91b-54c31d6ca2e3', 'b38f667d-3676-41df-87ee-e5be3c49a14c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('43656a7f-e326-443a-b91b-54c31d6ca2e3', 'd09dd9a9-d754-4f32-a2ca-5076293e4002');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', 'd79c919d-7f55-41fc-bcce-5fd3ba8d1ef5');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '8b7e845a-3359-4e5a-83e8-a37127582028');
-- Product Tags