package com.rsvadhis.java.javawindowsinstaller;

import java.awt.EventQueue;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

import net.miginfocom.swing.MigLayout;

public class GuiApp extends JFrame {
	Properties prop = new Properties();
	InputStream input = null;

	public GuiApp() throws IOException {
		InputStream input = getClass().getResourceAsStream(
				"/application.properties");
		prop.load(input);
		initUI();
	}

	private void initUI() {

		JFrame frame = new JFrame("Java Windows Installer Demo");
		frame.setSize(700, 400);
		frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);

		JPanel panel = new JPanel();
		frame.getContentPane().add(panel);
		panel.setLayout(new MigLayout("", "[][][]", "[][][][][][]"));

		JLabel lblPropertyone = new JLabel("property.one:");
		panel.add(lblPropertyone, "cell 1 1");

		JLabel lblNewLabel = new JLabel(prop.getProperty("property.one"));
		panel.add(lblNewLabel, "cell 2 1");

		JLabel lblPropertytwo = new JLabel("property.two:");
		panel.add(lblPropertytwo, "cell 1 2");

		JLabel label = new JLabel(prop.getProperty("property.two"));
		panel.add(label, "cell 2 2");

		JLabel lblPropertythree = new JLabel("property.three:");
		panel.add(lblPropertythree, "cell 1 3");

		JLabel label_1 = new JLabel(prop.getProperty("property.three"));
		panel.add(label_1, "cell 2 3");

		JLabel lblPropertyfour = new JLabel("property.four:");
		panel.add(lblPropertyfour, "cell 1 4");

		JLabel label_2 = new JLabel(prop.getProperty("property.four"));
		panel.add(label_2, "cell 2 4");

		JLabel lblPropertyfive = new JLabel("property.five:");
		panel.add(lblPropertyfive, "cell 1 5");

		JLabel label_3 = new JLabel(prop.getProperty("property.five"));
		panel.add(label_3, "cell 2 5");
		frame.setVisible(true);
	}

	public static void main(String[] args) {

		EventQueue.invokeLater(new Runnable() {

			@Override
			public void run() {
				try {
					GuiApp ex = new GuiApp();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});
	}

}